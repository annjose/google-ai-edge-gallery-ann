import Foundation

enum ModelDownloadStatusType: String, Codable, CaseIterable {
    case notDownloaded = "NOT_DOWNLOADED"
    case inProgress = "IN_PROGRESS"
    case succeeded = "SUCCEEDED"
    case failed = "FAILED"
    
    var displayName: String {
        switch self {
        case .notDownloaded:
            return "Not Downloaded"
        case .inProgress:
            return "Downloading"
        case .succeeded:
            return "Downloaded"
        case .failed:
            return "Failed"
        }
    }
}

struct ModelDownloadStatus: Codable {
    let status: ModelDownloadStatusType
    let totalBytes: Int64
    let receivedBytes: Int64
    let errorMessage: String
    let bytesPerSecond: Int64
    let remainingMs: Int64
    
    var progress: Double {
        guard totalBytes > 0 else { return 0.0 }
        return Double(receivedBytes) / Double(totalBytes)
    }
    
    var formattedProgress: String {
        return String(format: "%.1f%%", progress * 100)
    }
    
    var formattedSpeed: String {
        guard bytesPerSecond > 0 else { return "0 B/s" }
        return ByteCountFormatter.string(fromByteCount: bytesPerSecond, countStyle: .binary) + "/s"
    }
    
    var formattedTimeRemaining: String {
        guard remainingMs > 0 else { return "Unknown" }
        let seconds = remainingMs / 1000
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes % 60)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds % 60)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    init(status: ModelDownloadStatusType = .notDownloaded,
         totalBytes: Int64 = 0,
         receivedBytes: Int64 = 0,
         errorMessage: String = "",
         bytesPerSecond: Int64 = 0,
         remainingMs: Int64 = 0) {
        self.status = status
        self.totalBytes = totalBytes
        self.receivedBytes = receivedBytes
        self.errorMessage = errorMessage
        self.bytesPerSecond = bytesPerSecond
        self.remainingMs = remainingMs
    }
}

enum ModelInitializationStatusType: String, Codable, CaseIterable {
    case notInitialized = "NOT_INITIALIZED"
    case initializing = "INITIALIZING"
    case initialized = "INITIALIZED"
    case error = "ERROR"
    
    var displayName: String {
        switch self {
        case .notInitialized:
            return "Not Initialized"
        case .initializing:
            return "Initializing"
        case .initialized:
            return "Ready"
        case .error:
            return "Error"
        }
    }
}

struct ModelInitializationStatus: Codable {
    let status: ModelInitializationStatusType
    let error: String
    
    init(status: ModelInitializationStatusType = .notInitialized, error: String = "") {
        self.status = status
        self.error = error
    }
    
    var isReady: Bool {
        return status == .initialized
    }
    
    var isLoading: Bool {
        return status == .initializing
    }
    
    var hasError: Bool {
        return status == .error && !error.isEmpty
    }
}

class ModelStatus: ObservableObject {
    @Published var downloadStatus: ModelDownloadStatus
    @Published var initializationStatus: ModelInitializationStatus
    
    init(downloadStatus: ModelDownloadStatus = ModelDownloadStatus(),
         initializationStatus: ModelInitializationStatus = ModelInitializationStatus()) {
        self.downloadStatus = downloadStatus
        self.initializationStatus = initializationStatus
    }
    
    var isDownloaded: Bool {
        return downloadStatus.status == .succeeded
    }
    
    var isDownloading: Bool {
        return downloadStatus.status == .inProgress
    }
    
    var isReady: Bool {
        return isDownloaded && initializationStatus.isReady
    }
    
    var canTry: Bool {
        return isDownloaded && !initializationStatus.isLoading
    }
    
    var displayStatus: String {
        if !isDownloaded {
            return downloadStatus.status.displayName
        }
        return initializationStatus.status.displayName
    }
}