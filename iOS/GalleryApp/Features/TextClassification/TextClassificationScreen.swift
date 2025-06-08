import SwiftUI

struct TextClassificationScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = TextClassificationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                inputSection
                
                classifyButton
                
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
            .navigationTitle("Text Classification")
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
            Text("Classify Text")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter text to analyze its sentiment, category, or other properties")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Text to Classify")
                .font(.headline)
            
            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if viewModel.inputText.isEmpty {
                            Text("Enter your text here...")
                                .foregroundColor(.secondary)
                                .padding(.leading, 12)
                                .padding(.top, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
            
            HStack {
                Text("Examples:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Positive") {
                    viewModel.inputText = "I love this new app! It's amazing and works perfectly."
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                
                Button("Negative") {
                    viewModel.inputText = "This service is terrible and doesn't work at all."
                }
                .font(.caption)
                .foregroundColor(.accentColor)
                
                Button("Neutral") {
                    viewModel.inputText = "The weather today is partly cloudy with mild temperatures."
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
    }
    
    private var classifyButton: some View {
        Button(action: viewModel.classifyText) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(viewModel.isLoading ? "Classifying..." : "Classify Text")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canClassify ? Color.accentColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canClassify)
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            Text("Analyzing text...")
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
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.results, id: \.category) { result in
                    TextClassificationResultRow(result: result)
                }
            }
            
            if let stats = viewModel.performanceStats {
                performanceStatsView(stats)
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "textformat.alt")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Ready to Classify")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Enter any text above and tap 'Classify Text' to analyze its sentiment, topic, or other properties using AI.")
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
                StatItem(label: "Analysis", value: "\(Int(stats.latency * 1000))ms")
                StatItem(label: "Categories", value: "\(viewModel.results.count)")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct TextClassificationResultRow: View {
    let result: TextClassificationResult
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.category)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(Int(result.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(result.score)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(result.scoreColor)
            }
            
            ProgressView(value: result.confidence)
                .progressViewStyle(LinearProgressViewStyle(tint: result.scoreColor))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    TextClassificationScreen(modelName: "BERT Sentiment")
}