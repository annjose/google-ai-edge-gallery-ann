import Foundation
import Combine

class ModelManagerViewModel: ObservableObject {
    @Published var models: [Model] = []
    @Published var modelStatuses: [String: ModelStatus] = [:]
    @Published var showImportPicker = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var task: GalleryTask?
    private var appContainer: AppContainer?
    private var cancellables = Set<AnyCancellable>()
    
    func setTask(_ task: GalleryTask, container: AppContainer) {
        self.task = task
        self.appContainer = container
        self.models = task.models
        subscribeToModelStatuses()
    }
    
    private func subscribeToModelStatuses() {
        guard let container = appContainer else { return }
        
        container.modelRepository.modelStatuses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statuses in
                self?.modelStatuses = statuses
            }
            .store(in: &cancellables)
    }
    
    func getStatus(for model: Model) -> ModelStatus {
        return modelStatuses[model.name] ?? ModelStatus()
    }
    
    func downloadModel(_ model: Model) {
        guard let container = appContainer else { return }
        
        container.downloadRepository.downloadModel(model)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadStatus in
                let status = ModelStatus(downloadStatus: downloadStatus)
                self?.updateModelStatus(status, for: model.name)
            }
            .store(in: &cancellables)
    }
    
    func deleteModel(_ model: Model) {
        Task {
            await appContainer?.modelRepository.removeModel(model)
            
            DispatchQueue.main.async {
                self.models.removeAll { $0.id == model.id }
            }
        }
    }
    
    func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importModel(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func importModel(from url: URL) {
        Task {
            do {
                guard let container = appContainer else { return }
                
                let fileName = url.lastPathComponent
                let modelName = fileName.replacingOccurrences(of: ".task", with: "")
                
                _ = try await container.fileManager.importModel(from: url, modelName: modelName)
                
                let importedModel = Model(
                    name: modelName,
                    downloadFileName: fileName,
                    url: url.absoluteString,
                    sizeInBytes: await container.fileManager.getFileSize(at: url) ?? 0,
                    imported: true
                )
                
                await container.modelRepository.addImportedModel(importedModel)
                
                DispatchQueue.main.async {
                    self.models.append(importedModel)
                    self.task?.addModel(importedModel)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateModelStatus(_ status: ModelStatus, for modelName: String) {
        Task {
            await appContainer?.modelRepository.updateModelStatus(status, for: modelName)
        }
    }
}