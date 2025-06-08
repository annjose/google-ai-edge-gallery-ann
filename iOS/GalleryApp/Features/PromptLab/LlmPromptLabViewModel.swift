import Foundation

class LlmPromptLabViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var response = ""
    @Published var isLoading = false
    @Published var model: Model?
    @Published var selectedTemplate: PromptTemplate?
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    
    var canGenerate: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && model != nil
    }
    
    let promptTemplates: [PromptTemplate] = [
        PromptTemplate(name: "Freeform", template: "{input}", description: "Enter any prompt"),
        PromptTemplate(name: "Summarize", template: "Please summarize the following text:\n\n{input}", description: "Summarize text"),
        PromptTemplate(name: "Rewrite Formal", template: "Please rewrite the following text in a formal tone:\n\n{input}", description: "Make text formal"),
        PromptTemplate(name: "Rewrite Casual", template: "Please rewrite the following text in a casual tone:\n\n{input}", description: "Make text casual"),
        PromptTemplate(name: "Code Python", template: "Write a Python function that {input}", description: "Generate Python code"),
        PromptTemplate(name: "Code Swift", template: "Write a Swift function that {input}", description: "Generate Swift code"),
        PromptTemplate(name: "Explain", template: "Please explain the following concept in simple terms:\n\n{input}", description: "Explain concepts")
    ]
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
        selectTemplate(promptTemplates.first!)
    }
    
    func selectTemplate(_ template: PromptTemplate) {
        selectedTemplate = template
        
        if template.name == "Freeform" {
            return
        }
        
        if inputText.isEmpty {
            inputText = template.template.replacingOccurrences(of: "{input}", with: "")
        }
    }
    
    func generateResponse() {
        guard canGenerate, let model = model, let template = selectedTemplate else { return }
        
        isLoading = true
        response = ""
        
        let prompt = template.template.replacingOccurrences(of: "{input}", with: inputText)
        
        Task {
            do {
                let result = try await performInference(prompt: prompt, model: model)
                
                DispatchQueue.main.async {
                    self.response = result.response
                    self.performanceStats = result.stats
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.response = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearAll() {
        inputText = ""
        response = ""
        performanceStats = nil
        selectTemplate(promptTemplates.first!)
    }
    
    func exportResponse() {
        guard !response.isEmpty else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [response],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func performInference(prompt: String, model: Model) async throws -> (response: String, stats: PerformanceStats) {
        let startTime = Date()
        
        await simulateInference()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 0.15,
            tokensPerSecond: 22.0,
            totalTokens: 75,
            latency: latency
        )
        
        let response = generateMockResponse(for: prompt)
        
        return (response, stats)
    }
    
    private func simulateInference() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.0...3.0) * 1_000_000_000))
    }
    
    private func generateMockResponse(for prompt: String) -> String {
        if prompt.lowercased().contains("summarize") {
            return "Here's a concise summary of the provided text: The main points include the key concepts and important details, presented in a clear and organized manner."
        } else if prompt.lowercased().contains("python") {
            return """
            ```python
            def example_function(param):
                \"\"\"
                This function performs the requested operation.
                \"\"\"
                result = param * 2
                return result
            ```
            """
        } else if prompt.lowercased().contains("swift") {
            return """
            ```swift
            func exampleFunction(_ param: Int) -> Int {
                // This function performs the requested operation
                let result = param * 2
                return result
            }
            ```
            """
        } else if prompt.lowercased().contains("formal") {
            return "I have reformulated the provided text using formal language and professional terminology, ensuring proper grammatical structure and elevated vocabulary."
        } else if prompt.lowercased().contains("casual") {
            return "Here's a more relaxed version of what you wrote, using everyday language and a conversational tone that's easier to read."
        } else {
            return "Based on your prompt, here's a comprehensive response that addresses your request. This AI model is running locally on your device, ensuring privacy and fast processing."
        }
    }
}