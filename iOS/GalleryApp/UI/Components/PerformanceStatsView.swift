import SwiftUI

struct PerformanceStatsView: View {
    let stats: PerformanceStats
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                
                metricsGrid
                
                explanationSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Performance Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "speedometer")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("Model Performance")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Real-time metrics from your last inference")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Time to First Token",
                value: stats.formattedTTFT,
                description: "Time until first response",
                icon: "timer"
            )
            
            MetricCard(
                title: "Tokens per Second",
                value: stats.formattedTPS,
                description: "Generation speed",
                icon: "speedometer"
            )
            
            MetricCard(
                title: "Total Latency",
                value: stats.formattedLatency,
                description: "End-to-end time",
                icon: "clock"
            )
            
            MetricCard(
                title: "Total Tokens",
                value: "\(stats.totalTokens)",
                description: "Generated tokens",
                icon: "textformat.abc"
            )
        }
    }
    
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Understanding the Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                ExplanationRow(
                    title: "Time to First Token (TTFT)",
                    explanation: "The time from when you send a prompt until the model starts generating the first token of the response."
                )
                
                ExplanationRow(
                    title: "Tokens per Second",
                    explanation: "How many tokens the model generates per second during the response generation phase."
                )
                
                ExplanationRow(
                    title: "Total Latency",
                    explanation: "The complete time from sending your prompt to receiving the full response."
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ExplanationRow: View {
    let title: String
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(explanation)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PerformanceStatsRow: View {
    let stats: PerformanceStats
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("TTFT")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(stats.formattedTTFT)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Speed")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(stats.formattedTPS)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Total")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(stats.formattedLatency)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(6)
    }
}

#Preview {
    PerformanceStatsView(stats: PerformanceStats(
        timeToFirstToken: 0.15,
        tokensPerSecond: 25.0,
        totalTokens: 75,
        latency: 3.2
    ))
}