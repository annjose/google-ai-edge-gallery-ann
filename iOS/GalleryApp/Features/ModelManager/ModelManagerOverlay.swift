import SwiftUI

struct ModelManagerOverlay: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var appContainer: AppContainer
    @StateObject private var viewModel = ModelManagerViewModel()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    navigationManager.hideModelManager()
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                modelManagerContent
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .onAppear {
            if let task = navigationManager.selectedTask {
                viewModel.setTask(task, container: appContainer)
            }
        }
    }
    
    private var modelManagerContent: some View {
        VStack(spacing: 0) {
            header
            Divider()
            modelsList
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") {
                    navigationManager.hideModelManager()
                }
                .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(navigationManager.selectedTask?.type.label ?? "Models")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Import") {
                    viewModel.showImportPicker = true
                }
                .foregroundColor(.accentColor)
                .fileImporter(
                    isPresented: $viewModel.showImportPicker,
                    allowedContentTypes: [.data],
                    allowsMultipleSelection: false
                ) { result in
                    viewModel.handleImportResult(result)
                }
            }
            
            if let task = navigationManager.selectedTask {
                HStack {
                    Image(systemName: task.icon)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                    
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var modelsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.models, id: \.id) { model in
                    ModelItemView(
                        model: model,
                        status: viewModel.getStatus(for: model),
                        onDownload: {
                            viewModel.downloadModel(model)
                        },
                        onTry: {
                            if let task = navigationManager.selectedTask {
                                navigationManager.navigateToTask(task.type, with: model)
                            }
                        },
                        onDelete: {
                            viewModel.deleteModel(model)
                        }
                    )
                }
                
                if viewModel.models.isEmpty {
                    emptyState
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Models Available")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Import a local model or check your internet connection to download models.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Import Model") {
                viewModel.showImportPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 40)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ModelManagerOverlay()
        .environmentObject(NavigationManager())
        .environmentObject(AppContainer.shared)
}