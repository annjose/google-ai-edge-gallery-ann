import SwiftUI
import Combine

enum AppTheme: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system
    @AppStorage("app_theme") private var storedTheme: String = AppTheme.system.rawValue
    
    private let dataStore: DataStoreRepositoryProtocol
    
    var colorScheme: ColorScheme? {
        currentTheme.colorScheme
    }
    
    private init() {
        self.dataStore = AppContainer.shared.dataStoreRepository
        loadStoredTheme()
    }
    
    private func loadStoredTheme() {
        if let theme = AppTheme(rawValue: storedTheme) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        storedTheme = theme.rawValue
        
        Task {
            await dataStore.saveTheme(theme.rawValue)
        }
    }
    
    func loadTheme() async {
        if let savedTheme = await dataStore.getTheme(),
           let theme = AppTheme(rawValue: savedTheme) {
            DispatchQueue.main.async {
                self.currentTheme = theme
                self.storedTheme = savedTheme
            }
        }
    }
}

extension ThemeManager {
    var primaryColor: Color {
        Color.accentColor
    }
    
    var backgroundColor: Color {
        Color(.systemBackground)
    }
    
    var secondaryBackgroundColor: Color {
        Color(.secondarySystemBackground)
    }
    
    var textColor: Color {
        Color(.label)
    }
    
    var secondaryTextColor: Color {
        Color(.secondaryLabel)
    }
    
    var errorColor: Color {
        Color(.systemRed)
    }
    
    var successColor: Color {
        Color(.systemGreen)
    }
    
    var warningColor: Color {
        Color(.systemOrange)
    }
}