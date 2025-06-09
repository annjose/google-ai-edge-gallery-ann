import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var storageUsed: Int64 = 0
    @Published var availableSpace: Int64 = 0
    @Published var showImportPicker = false
    @Published var showResetAlert = false
    
    private let appContainer = AppContainer.shared
    
    var formattedStorageUsed: String {
        ByteCountFormatter.string(fromByteCount: storageUsed, countStyle: .file)
    }
    
    var formattedAvailableSpace: String {
        ByteCountFormatter.string(fromByteCount: availableSpace, countStyle: .file)
    }
    
    func loadStorageInfo() {
        Task {
            let used = await calculateStorageUsed()
            let available = await calculateAvailableSpace()
            
            DispatchQueue.main.async {
                self.storageUsed = used
                self.availableSpace = available
            }
        }
    }
    
    private func calculateStorageUsed() async -> Int64 {
        let modelsDir = await appContainer.fileManager.getModelsDirectory()
        return await calculateDirectorySize(modelsDir)
    }
    
    private func calculateAvailableSpace() async -> Int64 {
        let documentsDir = await appContainer.fileManager.getDocumentsDirectory()
        
        do {
            let resourceValues = try documentsDir.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            return Int64(resourceValues.volumeAvailableCapacity ?? 0)
        } catch {
            return 0
        }
    }
    
    private func calculateDirectorySize(_ directory: URL) async -> Int64 {
        guard FileManager.default.fileExists(atPath: directory.path) else { return 0 }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            var totalSize: Int64 = 0
            
            for url in contents {
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                
                if resourceValues.isDirectory == true {
                    totalSize += await calculateDirectorySize(url)
                } else {
                    totalSize += Int64(resourceValues.fileSize ?? 0)
                }
            }
            
            return totalSize
        } catch {
            return 0
        }
    }
    
    func clearCache() {
        Task {
            do {
                let documentsDir = await appContainer.fileManager.getDocumentsDirectory()
                let cacheDir = documentsDir.appendingPathComponent(Constants.FileSystem.cacheDirectory)
                
                if FileManager.default.fileExists(atPath: cacheDir.path) {
                    try FileManager.default.removeItem(at: cacheDir)
                }
                
                DispatchQueue.main.async {
                    self.loadStorageInfo()
                }
            } catch {
                print("Failed to clear cache: \(error)")
            }
        }
    }
    
    func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importModel(from: url)
        case .failure(let error):
            print("Import failed: \(error)")
        }
    }
    
    private func importModel(from url: URL) {
        Task {
            do {
                let fileName = url.lastPathComponent
                let modelName = fileName.replacingOccurrences(of: ".task", with: "")
                
                _ = try await appContainer.fileManager.importModel(from: url, modelName: modelName)
                
                let importedModel = Model(
                    name: modelName,
                    downloadFileName: fileName,
                    url: url.absoluteString,
                    sizeInBytes: await appContainer.fileManager.getFileSize(at: url) ?? 0,
                    imported: true
                )
                
                await appContainer.modelRepository.addImportedModel(importedModel)
                
                DispatchQueue.main.async {
                    self.loadStorageInfo()
                }
            } catch {
                print("Failed to import model: \(error)")
            }
        }
    }
    
    func resetAppData() {
        Task {
            do {
                let documentsDir = await appContainer.fileManager.getDocumentsDirectory()
                
                let modelsDir = documentsDir.appendingPathComponent(Constants.FileSystem.modelsDirectory)
                let cacheDir = documentsDir.appendingPathComponent(Constants.FileSystem.cacheDirectory)
                
                if FileManager.default.fileExists(atPath: modelsDir.path) {
                    try FileManager.default.removeItem(at: modelsDir)
                }
                
                if FileManager.default.fileExists(atPath: cacheDir.path) {
                    try FileManager.default.removeItem(at: cacheDir)
                }
                
                UserDefaults.standard.removeObject(forKey: "app_theme")
                UserDefaults.standard.removeObject(forKey: "text_input_history")
                UserDefaults.standard.removeObject(forKey: "imported_models")
                
                DispatchQueue.main.async {
                    self.loadStorageInfo()
                }
            } catch {
                print("Failed to reset app data: \(error)")
            }
        }
    }
}
