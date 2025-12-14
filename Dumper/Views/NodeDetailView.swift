import SwiftUI

struct NodeDetailView: View {
    let node: ViewNode?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            Group {
                if let node {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            detailRow("Element", node.type)

                            detailRowIfPresent("Identifier", node.identifier.map { "\($0)" })
                            detailRowIfPresent("Label", node.label.map { "\($0)" })

                            detailRow("Frame", format(frame: node.frame))
                                .monospacedDigit()

                            detailRow("Selected", node.isSelected ? "true" : "false")
                        }
                        .font(.system(size: 12, design: .monospaced))
                    }
                } else {
                    Text("Select a node to see details.")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    // MARK: - Row helpers

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(title):")
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading) // consistent alignment
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailRowIfPresent(_ title: String, _ value: String?) -> some View {
        Group {
            if let value, !value.isEmpty {
                detailRow(title, value)
            }
        }
    }

    // MARK: - Formatting

    private func format(frame: CGRect) -> String {
        String(
            format: "{{%.1f, %.1f}, {%.1f, %.1f}}",
            frame.origin.x,
            frame.origin.y,
            frame.size.width,
            frame.size.height
        )
    }
}
