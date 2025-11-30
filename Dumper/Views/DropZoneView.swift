import SwiftUI

struct DropZoneView: View {
    @ObservedObject var viewModel: InspectorViewModel
    @Binding var isDragging: Bool
    
    // Assuming these are passed by the parent view that manages the pending state
    let pendingImageURL: URL?
    let pendingHierarchyURL: URL?

    var body: some View {
        VStack(spacing: 15) {
            
            // --- Conditional Content ---
            if pendingImageURL != nil || pendingHierarchyURL != nil {
                pendingFilesView
            } else {
                initialDropView
            }

            // --- Error Message (Always at bottom) ---
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(dropZoneOverlay)
    }

    // MARK: - Private Computed Properties

    private var initialDropView: some View {
        VStack(spacing: 15) {
            Text("Native Hierarchy Inspector")
                .font(.largeTitle.bold())

            Text("Drag and Drop Files Here")
                .font(.title2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 5) {
                Text("Required Files:")
                    .bold()
                Text("1. Screenshot (.png or .jpg)")
                Text("2. Hierarchy Dump (.txt from app.debugDescription)")
            }
            .padding(.horizontal, 40)
        }
    }

    private var pendingFilesView: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("Waiting for remaining file:")
                .font(.title2.bold())
                .foregroundColor(.primary)
                .padding(.bottom, 4)
            
            PendingRow(
                systemName: "photo",
                title: "Screenshot",
                fileURL: pendingImageURL
            )
            
            PendingRow(
                systemName: "doc.text",
                title: "Hierarchy Dump",
                fileURL: pendingHierarchyURL
            )
        }
        // Use padding and alignment once on the outer container
        .padding(.horizontal, 24)
    }

    private var dropZoneOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(isDragging ? Color.blue : Color.clear, style: StrokeStyle(lineWidth: 3, dash: [10]))
            .padding(20)
    }

    // MARK: - Nested Helper View

    private struct PendingRow: View {
        let systemName: String
        let title: String
        let fileURL: URL?

        var body: some View {
            HStack(spacing: 15) { // Changed alignment to default center
                Image(systemName: systemName)
                    .font(.title) // Slightly larger icon
                    .foregroundColor(fileURL == nil ? .secondary : .blue)
                
                if let fileURL {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.bold())
                        Text(fileURL.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Awaiting \(title.lowercased())...")
                        .foregroundColor(.secondary)
                        .font(.title3) // Kept title3, but ensure overall Vstack padding is balanced
                }
                Spacer() // Pushes content to the left
            }
            .frame(maxWidth: 420) // Defines max width for the content
            .frame(maxWidth: .infinity, alignment: .center) // Centers the content block
        }
    }
}
