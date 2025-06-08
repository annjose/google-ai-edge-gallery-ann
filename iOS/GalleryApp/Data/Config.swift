import Foundation

enum ConfigKey: String, CaseIterable, Codable {
    case maxTokens = "MAX_TOKENS"
    case topK = "TOPK"
    case topP = "TOPP"
    case temperature = "TEMPERATURE"
    case randomSeed = "RANDOM_SEED"
    case loraPath = "LORA_PATH"
    case maxSequenceLength = "MAX_SEQUENCE_LENGTH"
    case numSteps = "NUM_STEPS"
    case guidanceScale = "GUIDANCE_SCALE"
    case numInferenceThreads = "NUM_INFERENCE_THREADS"
    case delegate = "DELEGATE"
    case gpuDelegate = "GPU_DELEGATE"
    case useNnapi = "USE_NNAPI"
    case cpuNumThreads = "CPU_NUM_THREADS"
    case useXnnpack = "USE_XNNPACK"
    case useGpuDelegate = "USE_GPU_DELEGATE"
    case maxNewTokens = "MAX_NEW_TOKENS"
    
    var displayName: String {
        switch self {
        case .maxTokens: return "Max Tokens"
        case .topK: return "Top K"
        case .topP: return "Top P"
        case .temperature: return "Temperature"
        case .randomSeed: return "Random Seed"
        case .loraPath: return "LoRA Path"
        case .maxSequenceLength: return "Max Sequence Length"
        case .numSteps: return "Number of Steps"
        case .guidanceScale: return "Guidance Scale"
        case .numInferenceThreads: return "Inference Threads"
        case .delegate: return "Delegate"
        case .gpuDelegate: return "GPU Delegate"
        case .useNnapi: return "Use NNAPI"
        case .cpuNumThreads: return "CPU Threads"
        case .useXnnpack: return "Use XNNPACK"
        case .useGpuDelegate: return "Use GPU Delegate"
        case .maxNewTokens: return "Max New Tokens"
        }
    }
}

enum ValueType: String, Codable {
    case int = "INT"
    case float = "FLOAT"
    case double = "DOUBLE"
    case string = "STRING"
    case boolean = "BOOLEAN"
}

protocol Config: Codable {
    var configKey: ConfigKey { get }
    var valueType: ValueType { get }
    var defaultValue: Any { get }
    var displayName: String { get }
}

struct NumberSliderConfig: Config {
    let configKey: ConfigKey
    let valueType: ValueType
    let defaultValue: Any
    let minValue: Double
    let maxValue: Double
    let stepSize: Double
    
    var displayName: String {
        configKey.displayName
    }
    
    private enum CodingKeys: String, CodingKey {
        case configKey, valueType, defaultValue, minValue, maxValue, stepSize
    }
    
    init(configKey: ConfigKey, valueType: ValueType, defaultValue: Any, minValue: Double, maxValue: Double, stepSize: Double = 1.0) {
        self.configKey = configKey
        self.valueType = valueType
        self.defaultValue = defaultValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.stepSize = stepSize
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configKey = try container.decode(ConfigKey.self, forKey: .configKey)
        valueType = try container.decode(ValueType.self, forKey: .valueType)
        minValue = try container.decode(Double.self, forKey: .minValue)
        maxValue = try container.decode(Double.self, forKey: .maxValue)
        stepSize = try container.decode(Double.self, forKey: .stepSize)
        
        switch valueType {
        case .int:
            defaultValue = try container.decode(Int.self, forKey: .defaultValue)
        case .float:
            defaultValue = try container.decode(Float.self, forKey: .defaultValue)
        case .double:
            defaultValue = try container.decode(Double.self, forKey: .defaultValue)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid value type for NumberSliderConfig")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configKey, forKey: .configKey)
        try container.encode(valueType, forKey: .valueType)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(stepSize, forKey: .stepSize)
        
        switch valueType {
        case .int:
            try container.encode(defaultValue as! Int, forKey: .defaultValue)
        case .float:
            try container.encode(defaultValue as! Float, forKey: .defaultValue)
        case .double:
            try container.encode(defaultValue as! Double, forKey: .defaultValue)
        default:
            throw EncodingError.invalidValue(defaultValue, 
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid value type for NumberSliderConfig"))
        }
    }
}

struct BooleanSwitchConfig: Config {
    let configKey: ConfigKey
    let valueType: ValueType = .boolean
    let defaultValue: Any
    
    var displayName: String {
        configKey.displayName
    }
    
    private enum CodingKeys: String, CodingKey {
        case configKey, defaultValue
    }
    
    init(configKey: ConfigKey, defaultValue: Bool) {
        self.configKey = configKey
        self.defaultValue = defaultValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configKey = try container.decode(ConfigKey.self, forKey: .configKey)
        defaultValue = try container.decode(Bool.self, forKey: .defaultValue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configKey, forKey: .configKey)
        try container.encode(defaultValue as! Bool, forKey: .defaultValue)
    }
}

struct SegmentedButtonConfig: Config {
    let configKey: ConfigKey
    let valueType: ValueType
    let defaultValue: Any
    let options: [String]
    
    var displayName: String {
        configKey.displayName
    }
    
    private enum CodingKeys: String, CodingKey {
        case configKey, valueType, defaultValue, options
    }
    
    init(configKey: ConfigKey, valueType: ValueType, defaultValue: Any, options: [String]) {
        self.configKey = configKey
        self.valueType = valueType
        self.defaultValue = defaultValue
        self.options = options
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configKey = try container.decode(ConfigKey.self, forKey: .configKey)
        valueType = try container.decode(ValueType.self, forKey: .valueType)
        options = try container.decode([String].self, forKey: .options)
        
        switch valueType {
        case .string:
            defaultValue = try container.decode(String.self, forKey: .defaultValue)
        case .int:
            defaultValue = try container.decode(Int.self, forKey: .defaultValue)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid value type for SegmentedButtonConfig")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configKey, forKey: .configKey)
        try container.encode(valueType, forKey: .valueType)
        try container.encode(options, forKey: .options)
        
        switch valueType {
        case .string:
            try container.encode(defaultValue as! String, forKey: .defaultValue)
        case .int:
            try container.encode(defaultValue as! Int, forKey: .defaultValue)
        default:
            throw EncodingError.invalidValue(defaultValue,
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid value type for SegmentedButtonConfig"))
        }
    }
}

enum ConfigType: String, Codable {
    case numberSlider = "NumberSliderConfig"
    case booleanSwitch = "BooleanSwitchConfig"
    case segmentedButton = "SegmentedButtonConfig"
}

struct AnyConfig: Codable {
    let config: Config
    
    private enum CodingKeys: String, CodingKey {
        case type, config
    }
    
    init(_ config: Config) {
        self.config = config
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ConfigType.self, forKey: .type)
        
        switch type {
        case .numberSlider:
            config = try container.decode(NumberSliderConfig.self, forKey: .config)
        case .booleanSwitch:
            config = try container.decode(BooleanSwitchConfig.self, forKey: .config)
        case .segmentedButton:
            config = try container.decode(SegmentedButtonConfig.self, forKey: .config)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let numberConfig = config as? NumberSliderConfig {
            try container.encode(ConfigType.numberSlider, forKey: .type)
            try container.encode(numberConfig, forKey: .config)
        } else if let booleanConfig = config as? BooleanSwitchConfig {
            try container.encode(ConfigType.booleanSwitch, forKey: .type)
            try container.encode(booleanConfig, forKey: .config)
        } else if let segmentedConfig = config as? SegmentedButtonConfig {
            try container.encode(ConfigType.segmentedButton, forKey: .type)
            try container.encode(segmentedConfig, forKey: .config)
        }
    }
}