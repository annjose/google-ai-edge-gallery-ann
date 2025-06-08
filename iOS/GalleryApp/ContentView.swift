import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appContainer: AppContainer
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            ZStack {
                HomeScreen()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
                
                if navigationManager.showModelManager {
                    ModelManagerOverlay()
                        .environmentObject(navigationManager)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: navigationManager.showModelManager)
                }
            }
        }
        .environmentObject(navigationManager)
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .llmChat(let modelName):
            LlmChatScreen(modelName: modelName)
        case .llmPromptLab(let modelName):
            LlmPromptLabScreen(modelName: modelName)
        case .llmAskImage(let modelName):
            LlmAskImageScreen(modelName: modelName)
        case .imageClassification(let modelName):
            ImageClassificationScreen(modelName: modelName)
        case .imageGeneration(let modelName):
            ImageGenerationScreen(modelName: modelName)
        case .textClassification(let modelName):
            TextClassificationScreen(modelName: modelName)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContainer.shared)
        .environmentObject(AppLifecycleProvider.shared)
        .environmentObject(ThemeManager.shared)
}