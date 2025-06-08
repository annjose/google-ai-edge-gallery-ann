import SwiftUI

struct ConfigurationView: View {
    let model: Model
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ConfigurationViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection
                    
                    if model.configs.isEmpty {
                        emptyConfigSection
                    } else {
                        configurationSections
                    }
                }
                .padding()
            }
            .navigationTitle("Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveConfiguration()
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .onAppear {
                viewModel.setupConfiguration(for: model)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gearshape.2")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Adjust model parameters")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var emptyConfigSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Configuration Available")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("This model doesn't have any configurable parameters.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private var configurationSections: some View {
        VStack(spacing: 20) {
            ForEach(model.configs.indices, id: \.self) { index in
                let config = model.configs[index]
                ConfigurationItemView(
                    config: config,
                    value: viewModel.getValue(for: config.configKey),
                    onValueChange: { newValue in
                        viewModel.setValue(newValue, for: config.configKey)
                    }
                )
            }
            
            resetSection
        }
    }
    
    private var resetSection: some View {
        VStack(spacing: 12) {
            Divider()
            
            Button("Reset to Defaults") {
                viewModel.resetToDefaults()
            }
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ConfigurationItemView: View {
    let config: Config
    let value: Any?
    let onValueChange: (Any) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(config.displayName)
                .font(.headline)
                .fontWeight(.medium)
            
            configurationControl
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var configurationControl: some View {
        if let numberConfig = config as? NumberSliderConfig {
            NumberSliderView(
                config: numberConfig,
                value: value,
                onValueChange: onValueChange
            )
        } else if let booleanConfig = config as? BooleanSwitchConfig {
            BooleanSwitchView(
                config: booleanConfig,
                value: value as? Bool ?? false,
                onValueChange: onValueChange
            )
        } else if let segmentedConfig = config as? SegmentedButtonConfig {
            SegmentedButtonView(
                config: segmentedConfig,
                value: value,
                onValueChange: onValueChange
            )
        }
    }
}

struct NumberSliderView: View {
    let config: NumberSliderConfig
    let value: Any?
    let onValueChange: (Any) -> Void
    
    @State private var sliderValue: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(String(format: "%.2f", sliderValue))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Range: \(String(format: "%.0f", config.minValue)) - \(String(format: "%.0f", config.maxValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: $sliderValue,
                in: config.minValue...config.maxValue,
                step: config.stepSize
            ) { _ in
                onValueChange(sliderValue)
            }
        }
        .onAppear {
            if let doubleValue = value as? Double {
                sliderValue = doubleValue
            } else if let intValue = value as? Int {
                sliderValue = Double(intValue)
            } else if let floatValue = value as? Float {
                sliderValue = Double(floatValue)
            } else {
                sliderValue = config.defaultValue as? Double ?? config.minValue
            }
        }
    }
}

struct BooleanSwitchView: View {
    let config: BooleanSwitchConfig
    let value: Bool
    let onValueChange: (Any) -> Void
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { value },
            set: { onValueChange($0) }
        )) {
            Text("Enable \(config.displayName)")
                .font(.subheadline)
        }
    }
}

struct SegmentedButtonView: View {
    let config: SegmentedButtonConfig
    let value: Any?
    let onValueChange: (Any) -> Void
    
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Options", selection: $selectedIndex) {
                ForEach(config.options.indices, id: \.self) { index in
                    Text(config.options[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedIndex) { newIndex in
                let selectedOption = config.options[newIndex]
                onValueChange(selectedOption)
            }
        }
        .onAppear {
            if let stringValue = value as? String,
               let index = config.options.firstIndex(of: stringValue) {
                selectedIndex = index
            }
        }
    }
}

class ConfigurationViewModel: ObservableObject {
    @Published private var configValues: [ConfigKey: Any] = [:]
    private var model: Model?
    
    func setupConfiguration(for model: Model) {
        self.model = model
        
        for config in model.configs {
            configValues[config.configKey] = config.defaultValue
        }
    }
    
    func getValue(for key: ConfigKey) -> Any? {
        return configValues[key]
    }
    
    func setValue(_ value: Any, for key: ConfigKey) {
        configValues[key] = value
    }
    
    func resetToDefaults() {
        guard let model = model else { return }
        
        for config in model.configs {
            configValues[config.configKey] = config.defaultValue
        }
    }
    
    func saveConfiguration() {
        // TODO: Implement saving configuration to model
        guard let model = model else { return }
        
        for (key, value) in configValues {
            model.configValues[key.rawValue] = value
        }
    }
}

struct ConfigurationPanel: View {
    let model: Model?
    @State private var showConfiguration = false
    
    var body: some View {
        if let model = model, !model.configs.isEmpty {
            Button("Configure Model") {
                showConfiguration = true
            }
            .font(.caption)
            .foregroundColor(.accentColor)
            .sheet(isPresented: $showConfiguration) {
                ConfigurationView(model: model)
            }
        }
    }
}

#Preview {
    ConfigurationView(model: Model(
        name: "Test Model",
        downloadFileName: "test.task",
        url: "https://example.com",
        sizeInBytes: 1000,
        configs: [
            NumberSliderConfig(
                configKey: .temperature,
                valueType: .double,
                defaultValue: 0.7,
                minValue: 0.0,
                maxValue: 1.0,
                stepSize: 0.1
            ),
            BooleanSwitchConfig(
                configKey: .useGpuDelegate,
                defaultValue: true
            )
        ]
    ))
}