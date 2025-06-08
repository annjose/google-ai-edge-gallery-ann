import SwiftUI

struct ImageGenerationScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = ImageGenerationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    promptSection
                    
                    generateButton
                    
                    if viewModel.isLoading {
                        loadingSection
                    } else if let generatedImage = viewModel.generatedImage {
                        generatedImageSection(generatedImage)
                    } else {
                        placeholderSection
                    }
                }
                .padding()
            }
            .navigationTitle("Image Generation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.setupModel(named: modelName)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Generate Images")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Describe what you want to see and AI will create an image for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prompt")
                .font(.headline)
            
            TextEditor(text: $viewModel.prompt)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
            
            Text("Example: \"A serene landscape with mountains and a lake at sunset\"")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var generateButton: some View {
        Button(action: viewModel.generateImage) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(viewModel.isLoading ? "Generating..." : "Generate Image")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canGenerate ? Color.accentColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canGenerate)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text("Creating your image...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("This may take a few moments")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    private func generatedImageSection(_ image: UIImage) -> some View {
        VStack(spacing: 16) {
            Text("Generated Image")
                .font(.headline)
                .fontWeight(.semibold)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(12)
                .shadow(radius: 4)
            
            HStack(spacing: 16) {
                Button("Save to Photos") {
                    viewModel.saveToPhotos()
                }
                .buttonStyle(.bordered)
                
                Button("Share") {
                    viewModel.shareImage()
                }
                .buttonStyle(.bordered)
                
                Button("Generate Again") {
                    viewModel.generateImage()
                }
                .buttonStyle(.borderedProminent)
            }
            
            if let stats = viewModel.performanceStats {
                performanceStatsView(stats)
            }
        }
    }
    
    private var placeholderSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Ready to Create")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Enter a detailed description of what you'd like to see and tap 'Generate Image' to create your artwork.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func performanceStatsView(_ stats: PerformanceStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Generation Stats")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                StatItem(label: "Time", value: "\(String(format: "%.1f", stats.latency))s")
                StatItem(label: "Steps", value: "50")
                StatItem(label: "Size", value: "512x512")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    ImageGenerationScreen(modelName: "Stable Diffusion")
}