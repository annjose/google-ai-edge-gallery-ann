import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    themeSelection
                }
                
                Section("Storage") {
                    storageInfo
                    clearCacheButton
                }
                
                Section("About") {
                    aboutInfo
                }
                
                Section("Advanced") {
                    importModelButton
                    resetAppButton
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadStorageInfo()
        }
    }
    
    private var themeSelection: some View {
        Picker("Theme", selection: $themeManager.currentTheme) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: themeManager.currentTheme) { newTheme in
            themeManager.setTheme(newTheme)
        }
    }
    
    private var storageInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Models Storage")
                Spacer()
                Text(viewModel.formattedStorageUsed)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Available Space")
                Spacer()
                Text(viewModel.formattedAvailableSpace)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var clearCacheButton: some View {
        Button("Clear Cache") {
            viewModel.clearCache()
        }
        .foregroundColor(.orange)
    }
    
    private var aboutInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Version")
                Spacer()
                Text(Constants.App.version)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                    .foregroundColor(.secondary)
            }
            
            Link("Source Code", destination: URL(string: "https://github.com/google-ai-edge/ai-edge-gallery")!)
                .foregroundColor(.accentColor)
            
            Link("Documentation", destination: URL(string: "https://ai.google.dev/edge/litert")!)
                .foregroundColor(.accentColor)
        }
    }
    
    private var importModelButton: some View {
        Button("Import Local Model") {
            viewModel.showImportPicker = true
        }
        .fileImporter(
            isPresented: $viewModel.showImportPicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleImportResult(result)
        }
    }
    
    private var resetAppButton: some View {
        Button("Reset App Data") {
            viewModel.showResetAlert = true
        }
        .foregroundColor(.red)
        .alert("Reset App Data", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAppData()
            }
        } message: {
            Text("This will delete all downloaded models and settings. This action cannot be undone.")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
}