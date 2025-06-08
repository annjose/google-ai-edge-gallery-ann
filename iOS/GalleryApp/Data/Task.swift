import Foundation
import SwiftUI

enum TaskType: String, CaseIterable, Codable {
    case textClassification = "TEXT_CLASSIFICATION"
    case imageClassification = "IMAGE_CLASSIFICATION" 
    case imageGeneration = "IMAGE_GENERATION"
    case llmChat = "LLM_CHAT"
    case llmPromptLab = "LLM_PROMPT_LAB"
    case llmAskImage = "LLM_ASK_IMAGE"
    
    var label: String {
        switch self {
        case .textClassification:
            return "Text Classification"
        case .imageClassification:
            return "Image Classification"
        case .imageGeneration:
            return "Image Generation"
        case .llmChat:
            return "AI Chat"
        case .llmPromptLab:
            return "Prompt Lab"
        case .llmAskImage:
            return "Ask Image"
        }
    }
    
    var id: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .textClassification:
            return "text.bubble"
        case .imageClassification:
            return "photo"
        case .imageGeneration:
            return "paintbrush"
        case .llmChat:
            return "message"
        case .llmPromptLab:
            return "terminal"
        case .llmAskImage:
            return "photo.badge.plus"
        }
    }
    
    var description: String {
        switch self {
        case .textClassification:
            return "Classify text into categories"
        case .imageClassification:
            return "Identify objects in images"
        case .imageGeneration:
            return "Generate images from text"
        case .llmChat:
            return "Multi-turn conversations with AI"
        case .llmPromptLab:
            return "Single-turn text tasks and prompts"
        case .llmAskImage:
            return "Ask questions about images"
        }
    }
}

class GalleryTask: ObservableObject, Identifiable {
    let id = UUID()
    let type: TaskType
    let icon: String
    @Published var models: [Model]
    let description: String
    let docUrl: String
    let sourceCodeUrl: String
    
    init(type: TaskType, 
         models: [Model] = [],
         description: String = "",
         docUrl: String = "",
         sourceCodeUrl: String = "") {
        self.type = type
        self.icon = type.icon
        self.models = models
        self.description = description.isEmpty ? type.description : description
        self.docUrl = docUrl
        self.sourceCodeUrl = sourceCodeUrl
    }
    
    func addModel(_ model: Model) {
        models.append(model)
    }
    
    func removeModel(_ model: Model) {
        models.removeAll { $0.id == model.id }
    }
}

extension GalleryTask: Equatable {
    static func == (lhs: GalleryTask, rhs: GalleryTask) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GalleryTask: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}