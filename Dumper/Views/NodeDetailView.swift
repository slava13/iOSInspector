import SwiftUI
import AppKit

// MARK: - NodeDetailView

struct NodeDetailView: View {
    let node: ViewNode?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            Group {
                if let node {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 10) {
                                detailRow("Element", node.type)

                                detailRowIfPresent("Identifier", node.identifier)
                                detailRowIfPresent("Label", node.label)

                                detailRow("Frame", format(frame: node.frame))
                                    .monospacedDigit()

                                detailRow("Selected", node.isSelected ? "true" : "false")
                            }
                            .font(.system(size: 12, design: .monospaced))

                            Divider()

                            VStack(alignment: .leading, spacing: 10) {
                                Text("UI Test Suggestions")
                                    .font(.headline)

                                let suggestions = LocatorSuggestionBuilder.suggestions(for: node)

                                ForEach(suggestions) { suggestion in
                                    SuggestionCard(suggestion: suggestion)
                                }
                            }
                        }
                        .padding(.bottom, 8)
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
                .frame(width: 90, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func detailRowIfPresent(_ title: String, _ value: String?) -> some View {
        Group {
            if let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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

// MARK: - Suggestion UI

private struct SuggestionCard: View {
    let suggestion: LocatorSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(suggestion.title)
                    .font(.system(size: 12, weight: suggestion.isRecommended ? .semibold : .regular))

                if suggestion.isRecommended {
                    Text("Recommended")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(6)
                }

                Spacer()

                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(suggestion.code, forType: .string)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            TextSuggestion
        }
    }
    
    private var TextSuggestion: some View {
        Text(suggestion.code)
            .font(.system(size: 11, design: .monospaced))
            .textSelection(.enabled)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(8)
    }
}
