import Foundation

struct HierarchySidebarState {
    var searchText = ""
    var selectedNodeID: ViewNode.ID?

    func visibleNodes(in hierarchyRoot: [ViewNode]) -> [(node: ViewNode, depth: Int)] {
        let nodes = flattenedNodes(in: hierarchyRoot)
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return nodes }

        let query = trimmedQuery.lowercased()
        return nodes.filter { entry in
            let typeMatch = entry.node.type.lowercased().contains(query)
            let identifierMatch = (entry.node.identifier ?? "").lowercased().contains(query)
            let labelMatch = (entry.node.label ?? "").lowercased().contains(query)
            return typeMatch || identifierMatch || labelMatch
        }
    }

    private func flattenedNodes(in hierarchyRoot: [ViewNode]) -> [(node: ViewNode, depth: Int)] {
        func flatten(_ nodes: [ViewNode], depth: Int) -> [(node: ViewNode, depth: Int)] {
            nodes.flatMap { node in
                [(node, depth)] + flatten(node.children, depth: depth + 1)
            }
        }

        return flatten(hierarchyRoot, depth: 0)
    }
}
