import CoreGraphics
import Foundation

struct ViewNode: Identifiable, Hashable {
    let id = UUID()
    let type: String
    let identifier: String?
    let label: String?
    let frame: CGRect
    var children: [ViewNode] = []

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
