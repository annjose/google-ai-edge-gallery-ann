import SwiftUI

struct LlmAskImageScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = LlmAskImageViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                chatMessages
                Divider()
                inputSection
            }
            .navigationTitle("Ask Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Clear Chat") {
                            viewModel.clearChat()
                        }
                        
                        Button("Show Stats") {
                            viewModel.showStats = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .sheet(isPresented: $viewModel.showStats) {
                if let stats = viewModel.performanceStats {
                    PerformanceStatsView(stats: stats)
                }
            }
            .onAppear {
                viewModel.setupModel(named: modelName)
            }
        }
    }
    
    private var chatMessages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        AskImageMessageView(message: message)
                    }
                    
                    if viewModel.isLoading {
                        LoadingMessageView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 12) {
            if let selectedImage = viewModel.selectedImage {
                selectedImagePreview(selectedImage)
            }
            
            HStack(spacing: 12) {
                Button(action: { viewModel.showImagePicker = true }) {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                
                TextField("Ask a question about the image...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...3)
                    .disabled(viewModel.isLoading)
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.canSendMessage ? .accentColor : .gray)
                }
                .disabled(!viewModel.canSendMessage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private func selectedImagePreview(_ image: UIImage) -> some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Selected Image")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("Tap to change")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Remove") {
                viewModel.selectedImage = nil
            }
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct AskImageMessageView: View {
    let message: AskImageMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
                messageContent
                    .background(Color.accentColor)
                    .foregroundColor(.white)
            } else {
                messageContent
                    .background(Color(.secondarySystemBackground))
                
                Spacer()
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let image = message.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
            }
            
            Text(message.content)
                .font(.body)
            
            if let timestamp = message.timestamp {
                Text(timestamp, style: .time)
                    .font(.caption2)
                    .opacity(0.7)
            }
            
            if let stats = message.performanceStats {
                PerformanceStatsRow(stats: stats)
            }
        }
        .padding(12)
        .cornerRadius(16)
    }
}

#Preview {
    LlmAskImageScreen(modelName: "Gemma 3N")
}