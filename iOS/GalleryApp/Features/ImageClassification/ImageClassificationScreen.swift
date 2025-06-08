import SwiftUI

struct ImageClassificationScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = ImageClassificationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                imageSection
                
                if viewModel.isLoading {
                    loadingSection
                } else if !viewModel.results.isEmpty {
                    resultsSection
                } else {
                    instructionsSection
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Image Classification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .onAppear {
                viewModel.setupModel(named: modelName)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Classify Images")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Upload an image to identify objects and get classification results")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 16) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            } else {
                imagePlaceholder
            }
            
            HStack(spacing: 16) {
                Button("Select Image") {
                    viewModel.showImagePicker = true
                }
                .buttonStyle(.bordered)
                
                if viewModel.selectedImage != nil {
                    Button("Classify") {
                        viewModel.classifyImage()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .frame(height: 200)
            .overlay(
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Tap 'Select Image' to choose a photo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            )
            .cornerRadius(12)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            Text("Classifying image...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Classification Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(viewModel.results, id: \.label) { result in
                    ClassificationResultRow(result: result)
                }
            }
            
            if let stats = viewModel.performanceStats {
                performanceStatsView(stats)
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "eye.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Ready to Classify")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Select an image from your photo library and tap 'Classify' to see what objects the AI can identify.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func performanceStatsView(_ stats: PerformanceStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                StatItem(label: "Inference", value: "\(Int(stats.latency * 1000))ms")
                StatItem(label: "Classes", value: "\(viewModel.results.count)")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct ClassificationResultRow: View {
    let result: ClassificationResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(result.confidence * 100))% confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ProgressView(value: result.confidence)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 100)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ImageClassificationScreen(modelName: "MobileNet V2")
}