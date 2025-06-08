import Foundation
import UIKit

struct ClassificationResult {
    let label: String
    let confidence: Double
}

class ImageClassificationViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var results: [ClassificationResult] = []
    @Published var isLoading = false
    @Published var showImagePicker = false
    @Published var model: Model?
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
    }
    
    func classifyImage() {
        guard let image = selectedImage, let model = model else { return }
        
        isLoading = true
        results = []
        
        Task {
            do {
                let (classificationResults, stats) = try await performClassification(image: image, using: model)
                
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
    
    private func performClassification(image: UIImage, using model: Model) async throws -> ([ClassificationResult], PerformanceStats) {
        let startTime = Date()
        
        await simulateClassification()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 0.05,
            tokensPerSecond: 0,
            totalTokens: 0,
            latency: latency
        )
        
        let results = generateMockClassificationResults()
        
        return (results, stats)
    }
    
    private func simulateClassification() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.5...1.5) * 1_000_000_000))
    }
    
    private func generateMockClassificationResults() -> [ClassificationResult] {
        let mockLabels = [
            "Cat", "Dog", "Bird", "Car", "Tree", "House", "Person", "Flower",
            "Computer", "Phone", "Book", "Chair", "Table", "Food", "Water", "Sky"
        ]
        
        let selectedLabels = Array(mockLabels.shuffled().prefix(5))
        
        return selectedLabels.enumerated().map { index, label in
            let confidence = Double.random(in: 0.1...0.95) * (index == 0 ? 1.0 : 0.8)
            return ClassificationResult(label: label, confidence: confidence)
        }.sorted { $0.confidence > $1.confidence }
    }
}