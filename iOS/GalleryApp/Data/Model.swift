import Foundation

struct ModelDataFile: Codable, Identifiable {
    let id = UUID()
    let filename: String
    let url: String
    let sizeInBytes: Int64
    
    private enum CodingKeys: String, CodingKey {
        case filename, url, sizeInBytes
    }
}

struct PromptTemplate: Codable, Identifiable {
    let id = UUID()
    let name: String
    let template: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case name, template, description
    }
}

class Model: ObservableObject, Codable, Identifiable {
    let id = UUID()
    let name: String
    let version: String
    let downloadFileName: String
    let url: String
    let sizeInBytes: Int64
    let extraDataFiles: [ModelDataFile]
    let info: String
    let learnMoreUrl: String
    let configs: [Config]
    let showRunAgainButton: Bool
    let showBenchmarkButton: Bool
    let isZip: Bool
    let unzipDir: String
    let llmPromptTemplates: [PromptTemplate]
    let llmSupportImage: Bool
    let imported: Bool
    
    @Published var normalizedName: String = ""
    @Published var instance: ModelInstance?
    @Published var initializing: Bool = false
    @Published var configValues: [String: Any] = [:]
    @Published var totalBytes: Int64 = 0
    @Published var accessToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case name, version, downloadFileName, url, sizeInBytes, extraDataFiles
        case info, learnMoreUrl, configs, showRunAgainButton, showBenchmarkButton
        case isZip, unzipDir, llmPromptTemplates, llmSupportImage, imported
        case normalizedName, totalBytes, accessToken
    }
    
    init(name: String, 
         version: String = "_",
         downloadFileName: String,
         url: String,
         sizeInBytes: Int64,
         extraDataFiles: [ModelDataFile] = [],
         info: String = "",
         learnMoreUrl: String = "",
         configs: [Config] = [],
         showRunAgainButton: Bool = true,
         showBenchmarkButton: Bool = true,
         isZip: Bool = false,
         unzipDir: String = "",
         llmPromptTemplates: [PromptTemplate] = [],
         llmSupportImage: Bool = false,
         imported: Bool = false) {
        
        self.name = name
        self.version = version
        self.downloadFileName = downloadFileName
        self.url = url
        self.sizeInBytes = sizeInBytes
        self.extraDataFiles = extraDataFiles
        self.info = info
        self.learnMoreUrl = learnMoreUrl
        self.configs = configs
        self.showRunAgainButton = showRunAgainButton
        self.showBenchmarkButton = showBenchmarkButton
        self.isZip = isZip
        self.unzipDir = unzipDir
        self.llmPromptTemplates = llmPromptTemplates
        self.llmSupportImage = llmSupportImage
        self.imported = imported
        
        self.normalizedName = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.totalBytes = sizeInBytes + extraDataFiles.reduce(0) { $0 + $1.sizeInBytes }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        version = try container.decodeIfPresent(String.self, forKey: .version) ?? "_"
        downloadFileName = try container.decode(String.self, forKey: .downloadFileName)
        url = try container.decode(String.self, forKey: .url)
        sizeInBytes = try container.decode(Int64.self, forKey: .sizeInBytes)
        extraDataFiles = try container.decodeIfPresent([ModelDataFile].self, forKey: .extraDataFiles) ?? []
        info = try container.decodeIfPresent(String.self, forKey: .info) ?? ""
        learnMoreUrl = try container.decodeIfPresent(String.self, forKey: .learnMoreUrl) ?? ""
        configs = try container.decodeIfPresent([Config].self, forKey: .configs) ?? []
        showRunAgainButton = try container.decodeIfPresent(Bool.self, forKey: .showRunAgainButton) ?? true
        showBenchmarkButton = try container.decodeIfPresent(Bool.self, forKey: .showBenchmarkButton) ?? true
        isZip = try container.decodeIfPresent(Bool.self, forKey: .isZip) ?? false
        unzipDir = try container.decodeIfPresent(String.self, forKey: .unzipDir) ?? ""
        llmPromptTemplates = try container.decodeIfPresent([PromptTemplate].self, forKey: .llmPromptTemplates) ?? []
        llmSupportImage = try container.decodeIfPresent(Bool.self, forKey: .llmSupportImage) ?? false
        imported = try container.decodeIfPresent(Bool.self, forKey: .imported) ?? false
        
        normalizedName = try container.decodeIfPresent(String.self, forKey: .normalizedName) ?? name.lowercased().replacingOccurrences(of: " ", with: "_")
        totalBytes = try container.decodeIfPresent(Int64.self, forKey: .totalBytes) ?? sizeInBytes
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(downloadFileName, forKey: .downloadFileName)
        try container.encode(url, forKey: .url)
        try container.encode(sizeInBytes, forKey: .sizeInBytes)
        try container.encode(extraDataFiles, forKey: .extraDataFiles)
        try container.encode(info, forKey: .info)
        try container.encode(learnMoreUrl, forKey: .learnMoreUrl)
        try container.encode(configs, forKey: .configs)
        try container.encode(showRunAgainButton, forKey: .showRunAgainButton)
        try container.encode(showBenchmarkButton, forKey: .showBenchmarkButton)
        try container.encode(isZip, forKey: .isZip)
        try container.encode(unzipDir, forKey: .unzipDir)
        try container.encode(llmPromptTemplates, forKey: .llmPromptTemplates)
        try container.encode(llmSupportImage, forKey: .llmSupportImage)
        try container.encode(imported, forKey: .imported)
        try container.encode(normalizedName, forKey: .normalizedName)
        try container.encode(totalBytes, forKey: .totalBytes)
        try container.encodeIfPresent(accessToken, forKey: .accessToken)
    }
}

protocol ModelInstance {
    func cleanup()
    func resetSession()
}

extension Model: Equatable {
    static func == (lhs: Model, rhs: Model) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Model: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}