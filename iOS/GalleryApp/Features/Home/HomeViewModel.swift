import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var tasks: [GalleryTask] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var appContainer: AppContainer?
    private var cancellables = Set<AnyCancellable>()
    
    func setContainer(_ container: AppContainer) {
        self.appContainer = container
        subscribeToTasks()
    }
    
    private func subscribeToTasks() {
        guard let container = appContainer else { return }
        
        container.modelRepository.tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.tasks = tasks.sorted { $0.type.label < $1.type.label }
            }
            .store(in: &cancellables)
    }
    
    func refreshTasks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                await appContainer?.modelRepository.loadModels()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}