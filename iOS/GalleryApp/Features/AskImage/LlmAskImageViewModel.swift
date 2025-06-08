import Foundation
import UIKit

struct AskImageMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let image: UIImage?
    let timestamp: Date?
    let performanceStats: PerformanceStats?
    
    init(content: String, isUser: Bool, image: UIImage? = nil, performanceStats: PerformanceStats? = nil) {
        self.content = content
        self.isUser = isUser
        self.image = image
        self.timestamp = Date()
        self.performanceStats = performanceStats
    }
}

class LlmAskImageViewModel: ObservableObject {
    @Published var messages: [AskImageMessage] = []
    @Published var inputText = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading = false
    @Published var model: Model?
    @Published var showImagePicker = false
    @Published var showStats = false
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    
    var canSendMessage: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        selectedImage != nil && 
        !isLoading
    }
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
        
        if model == nil {
            messages.append(AskImageMessage(
                content: "Model '\(modelName)' not found. Please download it first.",
                isUser: false
            ))
        } else {
            messages.append(AskImageMessage(
                content: "Welcome! Upload an image and ask me any questions about it. I can describe what I see, answer questions, or help solve problems in the image.",
                isUser: false
            ))
        }
    }
    
    func sendMessage() {
        guard canSendMessage, let model = model, let image = selectedImage else { return }
        
        let userMessage = AskImageMessage(
            content: inputText,
            isUser: true,
            image: image
        )
        messages.append(userMessage)
        
        let prompt = inputText
        inputText = ""
        let imageForAnalysis = selectedImage
        selectedImage = nil
        isLoading = true
        
        Task {
            do {
                let response = try await analyzeImage(image: imageForAnalysis!, prompt: prompt, using: model)
                
                DispatchQueue.main.async {
                    self.messages.append(response)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = AskImageMessage(
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
        selectedImage = nil
        inputText = ""
        
        messages.append(AskImageMessage(
            content: "Chat cleared. Upload an image and ask me questions about it!",
            isUser: false
        ))
    }
    
    private func analyzeImage(image: UIImage, prompt: String, using model: Model) async throws -> AskImageMessage {
        let startTime = Date()
        
        await simulateAnalysis()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 0.2,
            tokensPerSecond: 18.0,
            totalTokens: 85,
            latency: latency
        )
        
        self.performanceStats = stats
        
        let responseContent = generateImageAnalysisResponse(for: prompt, analyzing: image)
        
        return AskImageMessage(
            content: responseContent,
            isUser: false,
            performanceStats: stats
        )
    }
    
    private func simulateAnalysis() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.5...3.5) * 1_000_000_000))
    }
    
    private func generateImageAnalysisResponse(for prompt: String, analyzing image: UIImage) -> String {
        let promptLower = prompt.lowercased()
        
        if promptLower.contains("what") && (promptLower.contains("see") || promptLower.contains("image")) {
            return "I can see an image that appears to contain various visual elements. The image has different colors, shapes, and possibly objects or text. Based on the visual analysis, this appears to be a typical photograph or digital image with standard composition and lighting."
        } else if promptLower.contains("color") {
            return "The image contains a variety of colors. I can identify several distinct color regions and tones throughout the composition. The color palette appears to be well-balanced with both lighter and darker areas."
        } else if promptLower.contains("text") || promptLower.contains("read") {
            return "I'm analyzing the image for any text content. If there is text present in the image, I can attempt to read and transcribe it. However, text recognition accuracy depends on the clarity and orientation of the text in the image."
        } else if promptLower.contains("count") || promptLower.contains("how many") {
            return "I'm examining the image to count the objects you're asking about. Based on my visual analysis, I can identify multiple distinct elements in the image, though exact counts depend on the specific objects you're interested in."
        } else if promptLower.contains("describe") {
            return "This image shows a composition with various visual elements arranged in a typical photographic format. The lighting appears natural and the image quality suggests it was captured with a standard camera or mobile device. The overall scene has good contrast and appears to be well-focused."
        } else {
            return "Based on my analysis of the image and your question '\(prompt)', I can provide insights about the visual content. The image contains various elements that I can analyze and describe in detail. What specific aspects would you like me to focus on?"
        }
    }
}