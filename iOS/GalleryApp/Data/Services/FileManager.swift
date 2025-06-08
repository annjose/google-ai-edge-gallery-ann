import Foundation

protocol FileManagerProtocol {
    func getDocumentsDirectory() async -> URL
    func getModelsDirectory() async -> URL
    func getModelPath(for modelName: String) async -> URL
    func fileExists(at url: URL) async -> Bool
    func createDirectory(at url: URL) async throws
    func deleteModel(_ modelName: String) async throws
    func getFileSize(at url: URL) async -> Int64?
    func importModel(from sourceURL: URL, modelName: String) async throws -> URL
}

class GalleryFileManager: FileManagerProtocol {
    private let fileManager = FileManager.default
    
    func getDocumentsDirectory() async -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getModelsDirectory() async -> URL {
        let documentsDir = await getDocumentsDirectory()
        return documentsDir.appendingPathComponent(Constants.FileSystem.modelsDirectory)
    }
    
    func getModelPath(for modelName: String) async -> URL {
        let modelsDir = await getModelsDirectory()
        return modelsDir.appendingPathComponent("\(modelName).task")
    }
    
    func fileExists(at url: URL) async -> Bool {
        return fileManager.fileExists(atPath: url.path)
    }
    
    func createDirectory(at url: URL) async throws {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    func deleteModel(_ modelName: String) async throws {
        let modelPath = await getModelPath(for: modelName)
        
        if await fileExists(at: modelPath) {
            try fileManager.removeItem(at: modelPath)
        }
        
        let modelsDir = await getModelsDirectory()
        let modelDir = modelsDir.appendingPathComponent(modelName)
        
        if await fileExists(at: modelDir) {
            try fileManager.removeItem(at: modelDir)
        }
    }
    
    func getFileSize(at url: URL) async -> Int64? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
    func importModel(from sourceURL: URL, modelName: String) async throws -> URL {
        let modelsDir = await getModelsDirectory()
        
        if !(await fileExists(at: modelsDir)) {
            try await createDirectory(at: modelsDir)
        }
        
        let destinationURL = await getModelPath(for: modelName)
        
        if await fileExists(at: destinationURL) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        
        return destinationURL
    }
}