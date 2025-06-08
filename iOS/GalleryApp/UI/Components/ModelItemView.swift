import SwiftUI

struct ModelItemView: View {
    let model: Model
    let status: ModelStatus
    let onDownload: () -> Void
    let onTry: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            mainContent
            
            if isExpanded {
                expandedContent
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
        .alert("Delete Model", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this model? This action cannot be undone.")
        }
    }
    
    private var mainContent: some View {
        HStack(spacing: 16) {
            statusIcon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(formattedSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if status.isDownloading {
                    downloadProgress
                }
            }
            
            Spacer()
            
            actionButton
        }
        .padding(16)
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            if !model.info.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(model.info)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            modelDetails
            
            if status.isDownloaded {
                deleteButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 40, height: 40)
            
            Image(systemName: statusIconName)
                .font(.title3)
                .foregroundColor(statusColor)
        }
    }
    
    private var downloadProgress: some View {
        VStack(alignment: .leading, spacing: 4) {
            ProgressView(value: status.downloadStatus.progress)
                .progressViewStyle(LinearProgressViewStyle())
            
            HStack {
                Text(status.downloadStatus.formattedProgress)
                    .font(.caption2)
                
                Spacer()
                
                Text(status.downloadStatus.formattedSpeed)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var actionButton: some View {
        Group {
            if status.isDownloading {
                Button("Cancel") {
                    // TODO: Implement cancel download
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            } else if status.canTry {
                Button("Try It") {
                    onTry()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else {
                Button("Download") {
                    onDownload()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
    
    private var modelDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            DetailRow(label: "Version", value: model.version)
            DetailRow(label: "Status", value: status.displayStatus)
            
            if !model.learnMoreUrl.isEmpty {
                HStack {
                    Text("Learn More")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Link("View", destination: URL(string: model.learnMoreUrl)!)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private var deleteButton: some View {
        Button("Delete Model") {
            showDeleteAlert = true
        }
        .foregroundColor(.red)
        .font(.caption)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status.downloadStatus.status {
        case .notDownloaded:
            return .gray
        case .inProgress:
            return .blue
        case .succeeded:
            return status.initializationStatus.isReady ? .green : .orange
        case .failed:
            return .red
        }
    }
    
    private var statusIconName: String {
        switch status.downloadStatus.status {
        case .notDownloaded:
            return "icloud.and.arrow.down"
        case .inProgress:
            return "icloud.and.arrow.down"
        case .succeeded:
            return status.initializationStatus.isReady ? "checkmark.circle" : "hourglass"
        case .failed:
            return "xmark.circle"
        }
    }
    
    private var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: model.totalBytes, countStyle: .file)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
        }
    }
}

#Preview {
    ModelItemView(
        model: Model(
            name: "Gemma 3B",
            downloadFileName: "gemma_3b.task",
            url: "https://example.com/model",
            sizeInBytes: 1024 * 1024 * 100,
            info: "A powerful 3B parameter language model"
        ),
        status: ModelStatus(),
        onDownload: {},
        onTry: {},
        onDelete: {}
    )
    .padding()
}