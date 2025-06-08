import SwiftUI
import Foundation

enum NavigationDestination: Hashable {
    case llmChat(modelName: String)
    case llmPromptLab(modelName: String)
    case llmAskImage(modelName: String)
    case imageClassification(modelName: String)
    case imageGeneration(modelName: String)
    case textClassification(modelName: String)
}

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var showModelManager = false
    @Published var selectedTask: GalleryTask?
    
    func showModelManagerFor(task: GalleryTask) {
        selectedTask = task
        showModelManager = true
    }
    
    func hideModelManager() {
        showModelManager = false
        selectedTask = nil
    }
    
    func navigateToTask(_ task: TaskType, with model: Model) {
        hideModelManager()
        
        let destination: NavigationDestination
        
        switch task {
        case .llmChat:
            destination = .llmChat(modelName: model.name)
        case .llmPromptLab:
            destination = .llmPromptLab(modelName: model.name)
        case .llmAskImage:
            destination = .llmAskImage(modelName: model.name)
        case .imageClassification:
            destination = .imageClassification(modelName: model.name)
        case .imageGeneration:
            destination = .imageGeneration(modelName: model.name)
        case .textClassification:
            destination = .textClassification(modelName: model.name)
        }
        
        navigationPath.append(destination)
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}