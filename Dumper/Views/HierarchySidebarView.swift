import SwiftUI

struct HierarchySidebarView: View {
    let hierarchyRoot: [ViewNode]
    @Binding var selectedNodeID: ViewNode.ID?
    @Binding var searchText: String
    let onSelectionChange: (ViewNode.ID?) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("View Hierarchy")
                .font(.headline)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ZStack {
                List(selection: $selectedNodeID) {
                    ForEach(visibleNodes, id: \.node.id) { entry in
                        Text(entry.node.displayName)
                            .font(.system(size: 11, design: .monospaced))
                            .padding(.leading, CGFloat(entry.depth) * 12)
                            .tag(entry.node.id)
                    }
                }

                if !searchText.isEmpty && visibleNodes.isEmpty {
                    Text("No matches")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
            .onChange(of: selectedNodeID) { id in
                onSelectionChange(id)
            }
            .onChange(of: searchText) { _ in
                guard let selectedID = selectedNodeID else { return }
                if !visibleNodes.contains(where: { $0.node.id == selectedID }) {
                    selectedNodeID = nil
                    onSelectionChange(nil)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search (type, identifier, label)")
    }
}

private extension HierarchySidebarView {
    var visibleNodes: [(node: ViewNode, depth: Int)] {
        let nodes = flattenedNodes
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

    var flattenedNodes: [(node: ViewNode, depth: Int)] {
        func flatten(_ nodes: [ViewNode], depth: Int) -> [(node: ViewNode, depth: Int)] {
            nodes.flatMap { node in
                [(node, depth)] + flatten(node.children, depth: depth + 1)
            }
        }

        return flatten(hierarchyRoot, depth: 0)
    }
}
