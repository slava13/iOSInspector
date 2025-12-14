import SwiftUI

struct NodeDetailView: View {
    let node: ViewNode?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            if let node {
                VStack(alignment: .leading, spacing: 8) {
                    detailLine(title: "Element", value: node.type)

                    if let identifier = node.identifier, !identifier.isEmpty {
                        detailLine(title: "Identifier", value: "'\(identifier)'")
                    }

                    if let label = node.label, !label.isEmpty {
                        detailLine(title: "Label", value: "'\(label)'")
                    }

                    detailLine(title: "Frame", value: format(frame: node.frame))

                    if node.isSelected {
                        Text("Selected")
                    }
                }
                .font(.system(size: 12, design: .monospaced))
            } else {
                Text("Select a node to see details.")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    private func detailLine(title: String, value: String) -> some View {
        Text("\(title): \(value)")
    }

    private func format(frame: CGRect) -> String {
        String(
            format: "{{%.1f, %.1f}, {%.1f, %.1f}}",
            Double(frame.origin.x),
            Double(frame.origin.y),
            Double(frame.size.width),
            Double(frame.size.height)
        )
    }
}
