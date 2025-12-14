import AppKit
import SwiftUI

struct NodeDetailView: View {
    let viewState: NodeDetailState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            if viewState.hasNode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(viewState.detailLines, id: \.self) { line in
                                detailRow(line.title, line.value)
                            }
                        }
                        .font(.system(size: 12, design: .monospaced))

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("UI Test Suggestions")
                                .font(.headline)

                            ForEach(viewState.suggestions) { suggestion in
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

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(title):")
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

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

            Text(suggestion.code)
                .font(.system(size: 11, design: .monospaced))
                .textSelection(.enabled)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(8)
        }
    }
}
