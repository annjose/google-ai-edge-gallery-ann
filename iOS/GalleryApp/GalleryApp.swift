import SwiftUI

@main
struct GalleryApp: App {
    @StateObject private var appContainer = AppContainer.shared
    @StateObject private var lifecycleProvider = AppLifecycleProvider.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        setupApp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appContainer)
                .environmentObject(lifecycleProvider)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    Task {
                        await loadInitialData()
                    }
                }
        }
    }
    
    private func setupApp() {
        configureAppearance()
    }
    
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    private func loadInitialData() async {
        await appContainer.modelRepository.loadModels()
        await themeManager.loadTheme()
    }
}