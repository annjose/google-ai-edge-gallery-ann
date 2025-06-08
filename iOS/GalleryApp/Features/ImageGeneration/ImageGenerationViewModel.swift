import Foundation
import UIKit

class ImageGenerationViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var generatedImage: UIImage?
    @Published var isLoading = false
    @Published var model: Model?
    @Published var performanceStats: PerformanceStats?
    
    private let appContainer = AppContainer.shared
    
    var canGenerate: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && model != nil
    }
    
    func setupModel(named modelName: String) {
        model = appContainer.modelRepository.getModel(named: modelName)
    }
    
    func generateImage() {
        guard canGenerate, let model = model else { return }
        
        isLoading = true
        generatedImage = nil
        
        Task {
            do {
                let (image, stats) = try await performImageGeneration(prompt: prompt, using: model)
                
                DispatchQueue.main.async {
                    self.generatedImage = image
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
    
    func saveToPhotos() {
        guard let image = generatedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func shareImage() {
        guard let image = generatedImage else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image, prompt],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func performImageGeneration(prompt: String, using model: Model) async throws -> (UIImage, PerformanceStats) {
        let startTime = Date()
        
        await simulateGeneration()
        
        let endTime = Date()
        let latency = endTime.timeIntervalSince(startTime)
        
        let stats = PerformanceStats(
            timeToFirstToken: 1.0,
            tokensPerSecond: 0,
            totalTokens: 0,
            latency: latency
        )
        
        let image = generatePlaceholderImage(for: prompt)
        
        return (image, stats)
    }
    
    private func simulateGeneration() async {
        try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 3.0...8.0) * 1_000_000_000))
    }
    
    private func generatePlaceholderImage(for prompt: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Create a gradient background
            let colors = [UIColor.systemBlue, UIColor.systemPurple, UIColor.systemPink]
            let randomColor1 = colors.randomElement() ?? UIColor.systemBlue
            let randomColor2 = colors.randomElement() ?? UIColor.systemPurple
            
            let gradient = CAGradientLayer()
            gradient.frame = CGRect(origin: .zero, size: size)
            gradient.colors = [randomColor1.cgColor, randomColor2.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            
            context.cgContext.saveGState()
            gradient.render(in: context.cgContext)
            context.cgContext.restoreGState()
            
            // Add some decorative elements
            let rect1 = CGRect(x: 100, y: 100, width: 120, height: 120)
            let rect2 = CGRect(x: 300, y: 250, width: 80, height: 80)
            let rect3 = CGRect(x: 150, y: 350, width: 200, height: 60)
            
            UIColor.white.withAlphaComponent(0.3).setFill()
            UIBezierPath(ovalIn: rect1).fill()
            UIBezierPath(roundedRect: rect2, cornerRadius: 20).fill()
            UIBezierPath(roundedRect: rect3, cornerRadius: 30).fill()
            
            // Add text overlay
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            
            let text = "Generated Image\n\"\(prompt.prefix(30))\""
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            let textRect = CGRect(x: 20, y: size.height - 80, width: size.width - 40, height: 60)
            attributedText.draw(in: textRect)
        }
    }
}