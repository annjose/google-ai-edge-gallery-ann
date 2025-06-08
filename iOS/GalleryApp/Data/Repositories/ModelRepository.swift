import Foundation
import Combine

protocol ModelRepositoryProtocol {
    var tasks: CurrentValueSubject<[GalleryTask], Never> { get }
    var modelStatuses: CurrentValueSubject<[String: ModelStatus], Never> { get }
    
    func loadModels() async
    func getTask(for type: TaskType) -> GalleryTask?
    func getModel(named name: String) -> Model?
    func addImportedModel(_ model: Model) async
    func removeModel(_ model: Model) async
    func updateModelStatus(_ status: ModelStatus, for modelName: String) async
}

class ModelRepository: ModelRepositoryProtocol, ObservableObject {
    let tasks = CurrentValueSubject<[GalleryTask], Never>([])
    let modelStatuses = CurrentValueSubject<[String: ModelStatus], Never>([:])
    
    private let dataStoreRepository: DataStoreRepositoryProtocol
    private let fileManager: FileManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStoreRepository: DataStoreRepositoryProtocol, fileManager: FileManagerProtocol) {
        self.dataStoreRepository = dataStoreRepository
        self.fileManager = fileManager
    }
    
    func loadModels() async {
        await loadAllowlistModels()
        await loadImportedModels()
        await updateModelStatuses()
    }
    
    private func loadAllowlistModels() async {
        let allowlistTasks = await loadModelAllowlist()
        
        DispatchQueue.main.async {
            self.tasks.send(allowlistTasks)
        }
    }
    
    private func loadModelAllowlist() async -> [GalleryTask] {
        guard let url = Bundle.main.url(forResource: "model_allowlist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let allowlist = try? JSONDecoder().decode(ModelAllowlist.self, from: data) else {
            return createDefaultTasks()
        }
        
        return convertAllowlistToTasks(allowlist)
    }
    
    private func loadImportedModels() async {
        let importedModels = await dataStoreRepository.getImportedModels()
        
        await MainActor.run {
            for model in importedModels {
                addModelToExistingTask(model)
            }
        }
    }
    
    private func updateModelStatuses() async {
        var statuses: [String: ModelStatus] = [:]
        
        for task in tasks.value {
            for model in task.models {
                let downloadStatus = await getDownloadStatus(for: model)
                let initStatus = ModelInitializationStatus()
                statuses[model.name] = ModelStatus(
                    downloadStatus: downloadStatus,
                    initializationStatus: initStatus
                )
            }
        }
        
        DispatchQueue.main.async {
            self.modelStatuses.send(statuses)
        }
    }
    
    private func getDownloadStatus(for model: Model) async -> ModelDownloadStatus {
        let modelPath = await fileManager.getModelPath(for: model.name)
        let exists = await fileManager.fileExists(at: modelPath)
        
        if exists {
            return ModelDownloadStatus(status: .succeeded, totalBytes: model.totalBytes, receivedBytes: model.totalBytes)
        } else {
            return ModelDownloadStatus(status: .notDownloaded)
        }
    }
    
    func getTask(for type: TaskType) -> GalleryTask? {
        return tasks.value.first { $0.type == type }
    }
    
    func getModel(named name: String) -> Model? {
        for task in tasks.value {
            if let model = task.models.first(where: { $0.name == name }) {
                return model
            }
        }
        return nil
    }
    
    func addImportedModel(_ model: Model) async {
        await MainActor.run {
            addModelToExistingTask(model)
        }
        
        let allImportedModels = getAllImportedModels()
        await dataStoreRepository.saveImportedModels(allImportedModels)
    }
    
    func removeModel(_ model: Model) async {
        await MainActor.run {
            var currentTasks = tasks.value
            for task in currentTasks {
                task.removeModel(model)
            }
            tasks.send(currentTasks)
        }
        
        if model.imported {
            let allImportedModels = getAllImportedModels()
            await dataStoreRepository.saveImportedModels(allImportedModels)
        }
        
        await fileManager.deleteModel(model.name)
    }
    
    func updateModelStatus(_ status: ModelStatus, for modelName: String) async {
        await MainActor.run {
            var currentStatuses = modelStatuses.value
            currentStatuses[modelName] = status
            modelStatuses.send(currentStatuses)
        }
    }
    
    private func addModelToExistingTask(_ model: Model) {
        var currentTasks = tasks.value
        
        let taskType = determineTaskType(for: model)
        
        if let existingTask = currentTasks.first(where: { $0.type == taskType }) {
            if !existingTask.models.contains(where: { $0.name == model.name }) {
                existingTask.addModel(model)
            }
        } else {
            let newTask = GalleryTask(type: taskType, models: [model])
            currentTasks.append(newTask)
        }
        
        tasks.send(currentTasks)
    }
    
    private func determineTaskType(for model: Model) -> TaskType {
        let name = model.name.lowercased()
        
        if name.contains("chat") || name.contains("llm") || name.contains("gemma") {
            if model.llmSupportImage {
                return .llmAskImage
            }
            return .llmChat
        } else if name.contains("image") && name.contains("generation") {
            return .imageGeneration
        } else if name.contains("image") {
            return .imageClassification
        } else if name.contains("text") {
            return .textClassification
        }
        
        return .llmChat
    }
    
    private func getAllImportedModels() -> [Model] {
        var importedModels: [Model] = []
        for task in tasks.value {
            importedModels.append(contentsOf: task.models.filter { $0.imported })
        }
        return importedModels
    }
    
    private func createDefaultTasks() -> [GalleryTask] {
        return [
            GalleryTask(
                type: .llmChat,
                description: "Multi-turn conversations with AI",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            ),
            GalleryTask(
                type: .llmPromptLab,
                description: "Single-turn text tasks and prompts",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            ),
            GalleryTask(
                type: .llmAskImage,
                description: "Ask questions about images",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            ),
            GalleryTask(
                type: .imageClassification,
                description: "Identify objects in images",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            ),
            GalleryTask(
                type: .imageGeneration,
                description: "Generate images from text",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            ),
            GalleryTask(
                type: .textClassification,
                description: "Classify text into categories",
                docUrl: "https://ai.google.dev/edge/litert",
                sourceCodeUrl: "https://github.com/google-ai-edge/ai-edge-gallery"
            )
        ]
    }
    
    private func convertAllowlistToTasks(_ allowlist: ModelAllowlist) -> [GalleryTask] {
        var taskDict: [TaskType: GalleryTask] = [:]
        
        for model in allowlist.models {
            let taskType = determineTaskType(for: model)
            
            if taskDict[taskType] == nil {
                taskDict[taskType] = GalleryTask(type: taskType)
            }
            
            taskDict[taskType]?.addModel(model)
        }
        
        return Array(taskDict.values)
    }
}

struct ModelAllowlist: Codable {
    let models: [Model]
}