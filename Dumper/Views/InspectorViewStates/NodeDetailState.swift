import CoreGraphics
import Foundation

struct NodeDetailState {
    struct DetailLine: Hashable {
        let title: String
        let value: String
    }

    var node: ViewNode?

    var detailLines: [DetailLine] {
        guard let node else { return [] }

        var lines: [DetailLine] = [
            DetailLine(title: "Element", value: node.type)
        ]

        if let identifier = node.identifier, !identifier.isEmpty {
            lines.append(DetailLine(title: "Identifier", value: "'\(identifier)'"))
        }

        if let label = node.label, !label.isEmpty {
            lines.append(DetailLine(title: "Label", value: "'\(label)'"))
        }

        lines.append(DetailLine(title: "Frame", value: formatted(frame: node.frame)))
        lines.append(DetailLine(title: "Selected", value: node.isSelected ? "true" : "false"))

        return lines
    }

    var isSelected: Bool {
        node?.isSelected == true
    }

    var hasNode: Bool {
        node != nil
    }

    var suggestions: [LocatorSuggestion] {
        guard let node else { return [] }
        return LocatorSuggestionBuilder.suggestions(for: node)
    }

    private func formatted(frame: CGRect) -> String {
        String(
            format: "{{%.1f, %.1f}, {%.1f, %.1f}}",
            Double(frame.origin.x),
            Double(frame.origin.y),
            Double(frame.size.width),
            Double(frame.size.height)
        )
    }
}
