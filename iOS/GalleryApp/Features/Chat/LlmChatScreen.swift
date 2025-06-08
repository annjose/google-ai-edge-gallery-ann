import SwiftUI

struct LlmChatScreen: View {
    let modelName: String
    
    @StateObject private var viewModel = LlmChatViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                chatMessages
                Divider()
                inputSection
            }
            .navigationTitle(modelName)
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
                        
                        Button("Configure") {
                            viewModel.showConfig = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showStats) {
                PerformanceStatsView(stats: viewModel.performanceStats)
            }
            .sheet(isPresented: $viewModel.showConfig) {
                if let model = viewModel.model {
                    ConfigurationView(model: model)
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
                        ChatMessageView(message: message)
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
            if !viewModel.model?.configs.isEmpty ?? true {
                ConfigurationPanel(model: viewModel.model)
            }
            
            HStack(spacing: 12) {
                TextField("Type your message...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...5)
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
}

struct ChatMessageView: View {
    let message: ChatMessage
    
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

struct LoadingMessageView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(i) * 0.2),
                                value: true
                            )
                    }
                }
                .padding(12)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            
            Spacer()
        }
    }
}

#Preview {
    LlmChatScreen(modelName: "Gemma 3B")
}