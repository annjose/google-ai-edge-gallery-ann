import Foundation
import Combine

protocol DownloadRepositoryProtocol {
    func downloadModel(_ model: Model) -> AnyPublisher<ModelDownloadStatus, Never>
    func cancelDownload(for model: Model)
    func getDownloadStatus(for model: Model) -> AnyPublisher<ModelDownloadStatus, Never>
}

class DownloadRepository: DownloadRepositoryProtocol, ObservableObject {
    private let networkService: NetworkServiceProtocol
    private let fileManager: FileManagerProtocol
    
    private var activeDownloads: [String: AnyCancellable] = [:]
    private var downloadStatuses = CurrentValueSubject<[String: ModelDownloadStatus], Never>([:])
    
    init(networkService: NetworkServiceProtocol, fileManager: FileManagerProtocol) {
        self.networkService = networkService
        self.fileManager = fileManager
    }
    
    func downloadModel(_ model: Model) -> AnyPublisher<ModelDownloadStatus, Never> {
        let modelKey = model.name
        
        if activeDownloads[modelKey] != nil {
            return getDownloadStatus(for: model)
        }
        
        let statusSubject = CurrentValueSubject<ModelDownloadStatus, Never>(
            ModelDownloadStatus(status: .inProgress, totalBytes: model.totalBytes)
        )
        
        updateStatus(ModelDownloadStatus(status: .inProgress, totalBytes: model.totalBytes), for: modelKey)
        
        guard let url = URL(string: model.url) else {
            let errorStatus = ModelDownloadStatus(
                status: .failed,
                errorMessage: "Invalid URL"
            )
            updateStatus(errorStatus, for: modelKey)
            statusSubject.send(errorStatus)
            statusSubject.send(completion: .finished)
            return statusSubject.eraseToAnyPublisher()
        }
        
        let downloadTask = Task {
            do {
                let destinationURL = await fileManager.getModelPath(for: model.name)
                
                try await checkModelRequirements(model)
                
                let downloadPublisher = networkService.download(from: url, to: destinationURL)
                
                let cancellable = downloadPublisher
                    .map { progress in
                        ModelDownloadStatus(
                            status: .inProgress,
                            totalBytes: progress.totalBytes,
                            receivedBytes: progress.receivedBytes,
                            bytesPerSecond: progress.bytesPerSecond,
                            remainingMs: Int64(progress.estimatedTimeRemaining * 1000)
                        )
                    }
                    .catch { error in
                        Just(ModelDownloadStatus(
                            status: .failed,
                            errorMessage: error.localizedDescription
                        ))
                    }
                    .handleEvents(
                        receiveOutput: { [weak self] status in
                            self?.updateStatus(status, for: modelKey)
                            statusSubject.send(status)
                        },
                        receiveCompletion: { [weak self] completion in
                            self?.activeDownloads.removeValue(forKey: modelKey)
                            
                            switch completion {
                            case .finished:
                                let successStatus = ModelDownloadStatus(
                                    status: .succeeded,
                                    totalBytes: model.totalBytes,
                                    receivedBytes: model.totalBytes
                                )
                                self?.updateStatus(successStatus, for: modelKey)
                                statusSubject.send(successStatus)
                                self?.downloadExtraFiles(for: model)
                            case .failure:
                                break
                            }
                            
                            statusSubject.send(completion: .finished)
                        }
                    )
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                
                activeDownloads[modelKey] = cancellable
                
            } catch {
                let errorStatus = ModelDownloadStatus(
                    status: .failed,
                    errorMessage: error.localizedDescription
                )
                updateStatus(errorStatus, for: modelKey)
                statusSubject.send(errorStatus)
                statusSubject.send(completion: .finished)
            }
        }
        
        return statusSubject.eraseToAnyPublisher()
    }
    
    func cancelDownload(for model: Model) {
        let modelKey = model.name
        activeDownloads[modelKey]?.cancel()
        activeDownloads.removeValue(forKey: modelKey)
        
        let cancelledStatus = ModelDownloadStatus(status: .notDownloaded)
        updateStatus(cancelledStatus, for: modelKey)
    }
    
    func getDownloadStatus(for model: Model) -> AnyPublisher<ModelDownloadStatus, Never> {
        return downloadStatuses
            .compactMap { statuses in
                statuses[model.name] ?? ModelDownloadStatus(status: .notDownloaded)
            }
            .eraseToAnyPublisher()
    }
    
    private func updateStatus(_ status: ModelDownloadStatus, for modelKey: String) {
        var currentStatuses = downloadStatuses.value
        currentStatuses[modelKey] = status
        downloadStatuses.send(currentStatuses)
    }
    
    private func checkModelRequirements(_ model: Model) async throws {
        let requiresAuth = try await networkService.checkHuggingFaceAuth(for: model)
        
        if !requiresAuth {
            throw DownloadError.authenticationRequired
        }
    }
    
    private func downloadExtraFiles(for model: Model) {
        guard !model.extraDataFiles.isEmpty else { return }
        
        Task {
            for extraFile in model.extraDataFiles {
                guard let url = URL(string: extraFile.url) else { continue }
                
                let modelsDir = await fileManager.getModelsDirectory()
                let modelDir = modelsDir.appendingPathComponent(model.name)
                
                do {
                    try await fileManager.createDirectory(at: modelDir)
                    let destinationURL = modelDir.appendingPathComponent(extraFile.filename)
                    
                    _ = try await networkService.download(from: url, to: destinationURL)
                        .last()
                        .eraseToAnyPublisher()
                        .async()
                } catch {
                    print("Failed to download extra file \(extraFile.filename): \(error)")
                }
            }
        }
    }
}

enum DownloadError: LocalizedError {
    case authenticationRequired
    case insufficientStorage
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .authenticationRequired:
            return "Authentication required for this model"
        case .insufficientStorage:
            return "Insufficient storage space"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}

extension Publisher {
    func async() async throws -> Output where Failure == Error {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                },
                receiveValue: { value in
                    continuation.resume(returning: value)
                }
            )
        }
    }
}