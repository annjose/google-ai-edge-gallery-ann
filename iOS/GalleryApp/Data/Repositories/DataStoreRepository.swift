import Foundation
import Security

protocol DataStoreRepositoryProtocol {
    func saveTheme(_ theme: String) async
    func getTheme() async -> String?
    func saveTextInputHistory(_ history: [String]) async
    func getTextInputHistory() async -> [String]
    func saveAccessToken(_ token: String, for key: String) async throws
    func getAccessToken(for key: String) async throws -> String?
    func removeAccessToken(for key: String) async throws
    func saveImportedModels(_ models: [Model]) async
    func getImportedModels() async -> [Model]
}

class DataStoreRepository: DataStoreRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainService()
    
    private enum Keys {
        static let theme = "app_theme"
        static let textInputHistory = "text_input_history"
        static let importedModels = "imported_models"
    }
    
    func saveTheme(_ theme: String) async {
        userDefaults.set(theme, forKey: Keys.theme)
    }
    
    func getTheme() async -> String? {
        return userDefaults.string(forKey: Keys.theme)
    }
    
    func saveTextInputHistory(_ history: [String]) async {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: Keys.textInputHistory)
        }
    }
    
    func getTextInputHistory() async -> [String] {
        guard let data = userDefaults.data(forKey: Keys.textInputHistory),
              let history = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return history
    }
    
    func saveAccessToken(_ token: String, for key: String) async throws {
        try await keychain.save(token, for: key)
    }
    
    func getAccessToken(for key: String) async throws -> String? {
        return try await keychain.get(key)
    }
    
    func removeAccessToken(for key: String) async throws {
        try await keychain.delete(key)
    }
    
    func saveImportedModels(_ models: [Model]) async {
        if let data = try? JSONEncoder().encode(models) {
            userDefaults.set(data, forKey: Keys.importedModels)
        }
    }
    
    func getImportedModels() async -> [Model] {
        guard let data = userDefaults.data(forKey: Keys.importedModels),
              let models = try? JSONDecoder().decode([Model].self, from: data) else {
            return []
        }
        return models
    }
}

class KeychainService {
    private let serviceName = Constants.Storage.keychain
    
    func save(_ value: String, for key: String) async throws {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            if updateStatus != errSecSuccess {
                throw KeychainError.updateFailed
            }
        } else if status != errSecSuccess {
            throw KeychainError.saveFailed
        }
    }
    
    func get(_ key: String) async throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.getFailed
        }
        
        return string
    }
    
    func delete(_ key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed
        }
    }
}

enum KeychainError: Error {
    case saveFailed
    case updateFailed
    case getFailed
    case deleteFailed
    
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Failed to save to keychain"
        case .updateFailed:
            return "Failed to update keychain item"
        case .getFailed:
            return "Failed to retrieve from keychain"
        case .deleteFailed:
            return "Failed to delete from keychain"
        }
    }
}