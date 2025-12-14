import CoreGraphics
import Foundation

struct ViewNode: Identifiable, Hashable {
    let id = UUID()
    let type: String
    let identifier: String?
    let label: String?
    let frame: CGRect
    var isSelected: Bool = false
    var children: [ViewNode] = []

    init(
        type: String,
        identifier: String?,
        label: String?,
        frame: CGRect,
        isSelected: Bool = false,
        children: [ViewNode] = []
    ) {
        self.type = type
        self.identifier = identifier
        self.label = label
        self.frame = frame
        self.isSelected = isSelected
        self.children = children
    }

    var childrenOrNil: [ViewNode]? {
        children.isEmpty ? nil : children
    }

    var displayName: String {
        if let identifier, !identifier.isEmpty {
            return "\(type) - identifier: '\(identifier)'"
        }
        if let label, !label.isEmpty {
            return "\(type) - label: '\(label)'"
        }
        return type
    }
}
