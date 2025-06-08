import SwiftUI

struct LlmPromptLabScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = LlmPromptLabViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if geometry.size.width > geometry.size.height {
                    horizontalLayout
                } else {
                    verticalLayout
                }
            }
        }
        .navigationTitle("Prompt Lab")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Clear All") {
                        viewModel.clearAll()
                    }
                    
                    Button("Export Response") {
                        viewModel.exportResponse()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            viewModel.setupModel(named: modelName)
        }
    }
    
    private var horizontalLayout: some View {
        HStack(spacing: 0) {
            inputSection
                .frame(maxWidth: .infinity)
            
            Divider()
            
            responseSection
                .frame(maxWidth: .infinity)
        }
    }
    
    private var verticalLayout: some View {
        VStack(spacing: 0) {
            inputSection
                .frame(maxHeight: .infinity)
            
            Divider()
            
            responseSection
                .frame(maxHeight: .infinity)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            promptTemplatesPicker
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    inputTextEditor
                    
                    generateButton
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
    }
    
    private var responseSection: some View {
        VStack(spacing: 0) {
            responseHeader
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        loadingIndicator
                    } else if !viewModel.response.isEmpty {
                        responseText
                        
                        if let stats = viewModel.performanceStats {
                            performanceStatsView(stats)
                        }
                    } else {
                        emptyResponsePlaceholder
                    }
                }
                .padding()
            }
        }
        .background(Color(.secondarySystemBackground))
    }
    
    private var promptTemplatesPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prompt Templates")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.promptTemplates, id: \.name) { template in
                        PromptTemplateChip(
                            template: template,
                            isSelected: viewModel.selectedTemplate?.name == template.name
                        ) {
                            viewModel.selectTemplate(template)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var inputTextEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Input")
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
        }
    }
    
    private var generateButton: some View {
        Button(action: viewModel.generateResponse) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text(viewModel.isLoading ? "Generating..." : "Generate")
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
    
    private var responseHeader: some View {
        HStack {
            Text("Response")
                .font(.headline)
            
            Spacer()
            
            if !viewModel.response.isEmpty {
                Button("Copy") {
                    UIPasteboard.general.string = viewModel.response
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var loadingIndicator: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            Text("Generating response...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var responseText: some View {
        Text(viewModel.response)
            .font(.body)
            .textSelection(.enabled)
    }
    
    private var emptyResponsePlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Response will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func performanceStatsView(_ stats: PerformanceStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                StatItem(label: "TTFT", value: stats.formattedTTFT)
                StatItem(label: "Speed", value: stats.formattedTPS)
                StatItem(label: "Latency", value: stats.formattedLatency)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct PromptTemplateChip: View {
    let template: PromptTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(template.name)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LlmPromptLabScreen(modelName: "Gemma 3B")
}