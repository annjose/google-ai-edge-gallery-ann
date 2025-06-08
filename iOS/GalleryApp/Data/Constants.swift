import Foundation

struct Constants {
    struct App {
        static let name = "AI Edge Gallery"
        static let bundleIdentifier = "com.google.ai.edge.gallery"
        static let version = "1.0.0"
    }
    
    struct FileSystem {
        static let modelsDirectory = "models"
        static let cacheDirectory = "cache"
        static let tempDirectory = "temp"
        static let documentsDirectory = "documents"
    }
    
    struct ModelAllowlist {
        static let filename = "model_allowlist.json"
        static let url = "https://raw.githubusercontent.com/google-ai-edge/ai-edge-gallery/main/model_allowlist.json"
    }
    
    struct HuggingFace {
        static let baseURL = "https://huggingface.co"
        static let apiURL = "https://api.huggingface.co"
    }
    
    struct Network {
        static let defaultTimeout: TimeInterval = 30.0
        static let downloadTimeout: TimeInterval = 300.0
        static let maxRetries = 3
    }
    
    struct UI {
        static let animationDuration: Double = 0.3
        static let debounceDelay: Double = 0.5
        static let maxChatMessages = 100
        static let maxInputLength = 2000
    }
    
    struct Storage {
        static let userDefaults = "GalleryAppUserDefaults"
        static let keychain = "GalleryAppKeychain"
        static let coreData = "GalleryAppModel"
    }
    
    struct Performance {
        static let maxConcurrentDownloads = 2
        static let maxBackgroundTasks = 1
        static let memoryWarningThreshold = 0.8
    }
    
    struct Notifications {
        static let downloadComplete = "downloadComplete"
        static let downloadFailed = "downloadFailed"
        static let modelInitialized = "modelInitialized"
        static let memoryWarning = "memoryWarning"
    }
    
    struct AccessibilityIdentifiers {
        static let homeScreen = "homeScreen"
        static let chatView = "chatView"
        static let modelManager = "modelManager"
        static let promptLab = "promptLab"
        static let askImage = "askImage"
    }
}