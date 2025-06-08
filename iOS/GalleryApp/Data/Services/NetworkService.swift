import Foundation
import Combine

protocol NetworkServiceProtocol {
    func download(from url: URL, to destination: URL) -> AnyPublisher<DownloadProgress, Error>
    func fetch<T: Codable>(_ type: T.Type, from url: URL) async throws -> T
    func checkHuggingFaceAuth(for model: Model) async throws -> Bool
}

struct DownloadProgress {
    let totalBytes: Int64
    let receivedBytes: Int64
    let bytesPerSecond: Int64
    let estimatedTimeRemaining: TimeInterval
    
    var progress: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(receivedBytes) / Double(totalBytes)
    }
}

class NetworkService: NSObject, NetworkServiceProtocol {
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.Network.defaultTimeout
        config.timeoutIntervalForResource = Constants.Network.downloadTimeout
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private var progressHandlers: [URL: (DownloadProgress) -> Void] = [:]
    private var downloadStartTimes: [URL: Date] = [:]
    
    func download(from url: URL, to destination: URL) -> AnyPublisher<DownloadProgress, Error> {
        return Future<DownloadProgress, Error> { promise in
            self.downloadStartTimes[url] = Date()
            
            let progressSubject = PassthroughSubject<DownloadProgress, Error>()
            
            self.progressHandlers[url] = { progress in
                progressSubject.send(progress)
            }
            
            let task = self.session.downloadTask(with: url) { localURL, response, error in
                defer {
                    self.progressHandlers.removeValue(forKey: url)
                    self.downloadStartTimes.removeValue(forKey: url)
                }
                
                if let error = error {
                    progressSubject.send(completion: .failure(error))
                    return
                }
                
                guard let localURL = localURL else {
                    progressSubject.send(completion: .failure(NetworkError.downloadFailed))
                    return
                }
                
                do {
                    if FileManager.default.fileExists(atPath: destination.path) {
                        try FileManager.default.removeItem(at: destination)
                    }
                    
                    try FileManager.default.createDirectory(
                        at: destination.deletingLastPathComponent(),
                        withIntermediateDirectories: true
                    )
                    
                    try FileManager.default.moveItem(at: localURL, to: destination)
                    progressSubject.send(completion: .finished)
                } catch {
                    progressSubject.send(completion: .failure(error))
                }
            }
            
            task.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func fetch<T: Codable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func checkHuggingFaceAuth(for model: Model) async throws -> Bool {
        guard model.url.contains("huggingface.co") else {
            return true
        }
        
        let headRequest = URLRequest(url: URL(string: model.url)!)
        let (_, response) = try await session.data(for: headRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode != 401 && httpResponse.statusCode != 403
        }
        
        return true
    }
}

extension NetworkService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
              let handler = progressHandlers[url],
              let startTime = downloadStartTimes[url] else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let bytesPerSecond = elapsed > 0 ? Int64(Double(totalBytesWritten) / elapsed) : 0
        let remainingBytes = totalBytesExpectedToWrite - totalBytesWritten
        let estimatedTimeRemaining = bytesPerSecond > 0 ? Double(remainingBytes) / Double(bytesPerSecond) : 0
        
        let progress = DownloadProgress(
            totalBytes: totalBytesExpectedToWrite,
            receivedBytes: totalBytesWritten,
            bytesPerSecond: bytesPerSecond,
            estimatedTimeRemaining: estimatedTimeRemaining
        )
        
        DispatchQueue.main.async {
            handler(progress)
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case downloadFailed
    case decodingFailed(Error)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .downloadFailed:
            return "Download failed"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}