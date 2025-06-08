import Foundation
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date?
    let performanceStats: PerformanceStats?
    
    init(content: String, isUser: Bool, performanceStats: PerformanceStats? = nil) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.performanceStats = performanceStats
    }
}

struct PerformanceStats {
    let timeToFirstToken: Double
    let tokensPerSecond: Double
    let totalTokens: Int
    let latency: Double
    
    var formattedTTFT: String {
        String(format: "%.2f ms", timeToFirstToken * 1000)
    }
    
    var formattedTPS: String {
        String(format: "%.1f tok/s", tokensPerSecond)
    }
    
    var formattedLatency: String {
        String(format: "%.2f s", latency)
    }
}

class LlmChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var model: Model?
    @Published var showStats = false
    @Published var showConfig = false
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    private var cancellables = Set<AnyCancellable>()
    
    var canSendMessage: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
        
        if model == nil {
            messages.append(ChatMessage(
                content: "Model '\(modelName)' not found. Please download it first.",
                isUser: false
            ))
        }
    }
    
    func sendMessage() {
        guard canSendMessage, let model = model else { return }
        
        let userMessage = ChatMessage(content: inputText, isUser: true)
        messages.append(userMessage)
        
        let prompt = inputText
        inputText = ""
        isLoading = true
        
        Task {
            do {
                let response = try await generateResponse(for: prompt, using: model)
                
                DispatchQueue.main.async {
                    self.messages.append(response)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = ChatMessage(
                        content: "Error: \(error.localizedDescription)",
                        isUser: false
                    )
                    self.messages.append(errorMessage)
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearChat() {
        messages.removeAll()
        performanceStats = nil
    }
    
    private func generateResponse(for prompt: String, using model: Model) async throws -> ChatMessage {
        let startTime = Date()
        
        await simulateDelay()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 0.1,
            tokensPerSecond: 25.0,
            totalTokens: 50,
            latency: latency
        )
        
        self.performanceStats = stats
        
        let responseContent = generateMockResponse(for: prompt)
        
        return ChatMessage(
            content: responseContent,
            isUser: false,
            performanceStats: stats
        )
    }
    
    private func simulateDelay() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.5...2.0) * 1_000_000_000))
    }
    
    private func generateMockResponse(for prompt: String) -> String {
        let responses = [
            "I understand you're asking about '\(prompt)'. As an AI assistant running locally on your device, I can help you with various tasks. What specific information would you like to know?",
            "That's an interesting question about '\(prompt)'. Let me provide you with a comprehensive response based on my training data.",
            "Thank you for your question regarding '\(prompt)'. I'm processing this entirely on your device for privacy and speed.",
            "I see you're interested in '\(prompt)'. Here's what I can tell you about this topic...",
            "Your query about '\(prompt)' is quite thought-provoking. Let me break this down for you."
        ]
        
        return responses.randomElement() ?? "I'm here to help with your question about '\(prompt)'."
    }
}