import CoreGraphics
import AppKit
import Foundation

protocol HierarchyParsing {
    func parse(content: String) -> [ViewNode]
}

final class HierarchyParser: HierarchyParsing {
    private let frameRegex: NSRegularExpression

    init(frameRegex: NSRegularExpression = HierarchyParser.makeFrameRegex()) {
        self.frameRegex = frameRegex
    }

    func parse(content: String) -> [ViewNode] {
        var lines = content.components(separatedBy: .newlines)

        if let startIndex = lines.firstIndex(where: { $0.contains("Element subtree:") }) {
            lines = Array(lines.dropFirst(startIndex + 1))
        }

        var rootNodes: [ViewNode] = []
        var stack: [(node: ViewNode, indent: Int)] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let indent = line.prefix(while: { $0 == " " || $0 == "→" }).count
            let cleanLine = trimmed.replacingOccurrences(of: "→", with: "")
            let components = cleanLine.components(separatedBy: ", ")
            let type = components.first ?? "Element"

            let frame = parseFrame(in: line)
            let label = extractAttribute(in: line, key: "label")
            let identifier = extractAttribute(in: line, key: "identifier")

            let newNode = ViewNode(type: type, identifier: identifier, label: label, frame: frame)

            while let last = stack.last, last.indent >= indent {
                stack.removeLast()
            }

            if let parent = stack.last {
                insertChild(child: newNode, into: &rootNodes, parentId: parent.node.id)
            } else {
                rootNodes.append(newNode)
            }

            stack.append((newNode, indent))
        }

        return rootNodes
    }

    private static func makeFrameRegex() -> NSRegularExpression {
        let pattern = "\\{\\{(-?\\d+\\.?\\d*), (-?\\d+\\.?\\d*)\\}, \\{(-?\\d+\\.?\\d*), (-?\\d+\\.?\\d*)\\}\\}"
        return try! NSRegularExpression(pattern: pattern)
    }

    private func parseFrame(in line: String) -> CGRect {
        guard let match = frameRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              match.numberOfRanges == 5 else {
            return .zero
        }

        func value(at index: Int) -> CGFloat? {
            guard let range = Range(match.range(at: index), in: line) else { return nil }
            let stringValue = String(line[range])
            guard let doubleValue = Double(stringValue) else { return nil }
            return CGFloat(doubleValue)
        }

        guard
            let x = value(at: 1),
            let y = value(at: 2),
            let width = value(at: 3),
            let height = value(at: 4)
        else {
            return .zero
        }

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func extractAttribute(in line: String, key: String) -> String? {
        let pattern = "\(key): '(.*?)'"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }

        return String(line[range])
    }

    private func insertChild(child: ViewNode, into nodes: inout [ViewNode], parentId: UUID) {
        for index in 0..<nodes.count {
            if nodes[index].id == parentId {
                nodes[index].children.append(child)
                return
            }
            insertChild(child: child, into: &nodes[index].children, parentId: parentId)
        }
    }
}
