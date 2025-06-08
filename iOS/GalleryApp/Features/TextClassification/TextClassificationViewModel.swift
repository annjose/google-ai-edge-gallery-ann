import Foundation
import SwiftUI

struct TextClassificationResult {
    let category: String
    let confidence: Double
    let score: String
    
    var scoreColor: Color {
        switch category.lowercased() {
        case "positive":
            return .green
        case "negative":
            return .red
        case "neutral":
            return .orange
        default:
            return .blue
        }
    }
}

class TextClassificationViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var results: [TextClassificationResult] = []
    @Published var isLoading = false
    @Published var model: Model?
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    
    var canClassify: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && model != nil
    }
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
    }
    
    func classifyText() {
        guard canClassify, let model = model else { return }
        
        isLoading = true
        results = []
        
        Task {
            do {
                let (classificationResults, stats) = try await performTextClassification(text: inputText, using: model)
                
                DispatchQueue.main.async {
                    self.results = classificationResults
                    self.performanceStats = stats
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    // Handle error
                }
            }
        }
    }
    
    private func performTextClassification(text: String, using model: Model) async throws -> ([TextClassificationResult], PerformanceStats) {
        let startTime = Date()
        
        await simulateClassification()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 0.03,
            tokensPerSecond: 0,
            totalTokens: 0,
            latency: latency
        )
        
        let results = generateMockTextClassificationResults(for: text)
        
        return (results, stats)
    }
    
    private func simulateClassification() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.3...1.0) * 1_000_000_000))
    }
    
    private func generateMockTextClassificationResults(for text: String) -> [TextClassificationResult] {
        let textLower = text.lowercased()
        var results: [TextClassificationResult] = []
        
        // Sentiment analysis
        if textLower.contains("love") || textLower.contains("amazing") || textLower.contains("great") || textLower.contains("perfect") {
            results.append(TextClassificationResult(category: "Positive", confidence: 0.92, score: "😊"))
            results.append(TextClassificationResult(category: "Negative", confidence: 0.05, score: "😞"))
            results.append(TextClassificationResult(category: "Neutral", confidence: 0.03, score: "😐"))
        } else if textLower.contains("terrible") || textLower.contains("bad") || textLower.contains("awful") || textLower.contains("hate") {
            results.append(TextClassificationResult(category: "Negative", confidence: 0.89, score: "😞"))
            results.append(TextClassificationResult(category: "Positive", confidence: 0.06, score: "😊"))
            results.append(TextClassificationResult(category: "Neutral", confidence: 0.05, score: "😐"))
        } else {
            results.append(TextClassificationResult(category: "Neutral", confidence: 0.78, score: "😐"))
            results.append(TextClassificationResult(category: "Positive", confidence: 0.12, score: "😊"))
            results.append(TextClassificationResult(category: "Negative", confidence: 0.10, score: "😞"))
        }
        
        // Topic classification
        if textLower.contains("weather") || textLower.contains("temperature") || textLower.contains("rain") || textLower.contains("sunny") {
            results.append(TextClassificationResult(category: "Weather", confidence: 0.85, score: "🌤️"))
        } else if textLower.contains("app") || textLower.contains("software") || textLower.contains("technology") {
            results.append(TextClassificationResult(category: "Technology", confidence: 0.81, score: "💻"))
        } else if textLower.contains("food") || textLower.contains("restaurant") || textLower.contains("eat") {
            results.append(TextClassificationResult(category: "Food & Dining", confidence: 0.76, score: "🍽️"))
        }
        
        return results.sorted { $0.confidence > $1.confidence }
    }
}