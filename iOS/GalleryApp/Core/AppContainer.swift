import Foundation
import Combine

protocol AppContainerProtocol {
    var dataStoreRepository: DataStoreRepositoryProtocol { get }
    var downloadRepository: DownloadRepositoryProtocol { get }
    var modelRepository: ModelRepositoryProtocol { get }
    var networkService: NetworkServiceProtocol { get }
    var fileManager: FileManagerProtocol { get }
}

class AppContainer: AppContainerProtocol, ObservableObject {
    static let shared = AppContainer()
    
    private let _dataStoreRepository: DataStoreRepositoryProtocol
    private let _downloadRepository: DownloadRepositoryProtocol
    private let _modelRepository: ModelRepositoryProtocol
    private let _networkService: NetworkServiceProtocol
    private let _fileManager: FileManagerProtocol
    
    var dataStoreRepository: DataStoreRepositoryProtocol { _dataStoreRepository }
    var downloadRepository: DownloadRepositoryProtocol { _downloadRepository }
    var modelRepository: ModelRepositoryProtocol { _modelRepository }
    var networkService: NetworkServiceProtocol { _networkService }
    var fileManager: FileManagerProtocol { _fileManager }
    
    private init() {
        self._fileManager = GalleryFileManager()
        self._networkService = NetworkService()
        self._dataStoreRepository = DataStoreRepository()
        self._downloadRepository = DownloadRepository(
            networkService: _networkService,
            fileManager: _fileManager
        )
        self._modelRepository = ModelRepository(
            dataStoreRepository: _dataStoreRepository,
            fileManager: _fileManager
        )
    }
}

protocol LifecycleProvider {
    var isAppActive: AnyPublisher<Bool, Never> { get }
    var didBecomeActive: AnyPublisher<Void, Never> { get }
    var willResignActive: AnyPublisher<Void, Never> { get }
    var didEnterBackground: AnyPublisher<Void, Never> { get }
    var willEnterForeground: AnyPublisher<Void, Never> { get }
}

class AppLifecycleProvider: LifecycleProvider, ObservableObject {
    static let shared = AppLifecycleProvider()
    
    @Published private var _isAppActive = true
    
    private let didBecomeActiveSubject = PassthroughSubject<Void, Never>()
    private let willResignActiveSubject = PassthroughSubject<Void, Never>()
    private let didEnterBackgroundSubject = PassthroughSubject<Void, Never>()
    private let willEnterForegroundSubject = PassthroughSubject<Void, Never>()
    
    var isAppActive: AnyPublisher<Bool, Never> {
        $_isAppActive.eraseToAnyPublisher()
    }
    
    var didBecomeActive: AnyPublisher<Void, Never> {
        didBecomeActiveSubject.eraseToAnyPublisher()
    }
    
    var willResignActive: AnyPublisher<Void, Never> {
        willResignActiveSubject.eraseToAnyPublisher()
    }
    
    var didEnterBackground: AnyPublisher<Void, Never> {
        didEnterBackgroundSubject.eraseToAnyPublisher()
    }
    
    var willEnterForeground: AnyPublisher<Void, Never> {
        willEnterForegroundSubject.eraseToAnyPublisher()
    }
    
    private init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        _isAppActive = true
        didBecomeActiveSubject.send()
    }
    
    @objc private func appWillResignActive() {
        _isAppActive = false
        willResignActiveSubject.send()
    }
    
    @objc private func appDidEnterBackground() {
        didEnterBackgroundSubject.send()
    }
    
    @objc private func appWillEnterForeground() {
        willEnterForegroundSubject.send()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}