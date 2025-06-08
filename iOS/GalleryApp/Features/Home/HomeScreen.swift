import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var appContainer: AppContainer
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    headerSection
                    tasksGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("AI Edge Gallery")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                viewModel.setContainer(appContainer)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome to AI Edge Gallery")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Experience cutting-edge AI models running locally on your device")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
            }
            
            featureHighlights
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var featureHighlights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Features")
                .font(.headline)
                .fontWeight(.semibold)
            
            FeatureHighlightRow(
                icon: "wifi.slash",
                title: "Fully Offline",
                description: "No internet required after download"
            )
            
            FeatureHighlightRow(
                icon: "speedometer",
                title: "High Performance",
                description: "Real-time inference with benchmarks"
            )
            
            FeatureHighlightRow(
                icon: "lock.shield",
                title: "Privacy First",
                description: "All processing happens on-device"
            )
        }
    }
    
    private var tasksGrid: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose Your AI Task")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.tasks, id: \.id) { task in
                    TaskCard(task: task) {
                        navigationManager.showModelManagerFor(task: task)
                    }
                }
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape")
                .font(.title3)
        }
    }
}

struct FeatureHighlightRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct TaskCard: View {
    let task: GalleryTask
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: task.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                
                VStack(spacing: 8) {
                    Text(task.type.label)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                HStack {
                    Image(systemName: "cube.box")
                        .font(.caption)
                    Text("\(task.models.count) models")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeScreen()
        .environmentObject(AppContainer.shared)
        .environmentObject(NavigationManager())
        .environmentObject(ThemeManager.shared)
}