import SwiftUI

struct HierarchySidebarView: View {
    let hierarchyRoot: [ViewNode]
    @Binding var viewState: HierarchySidebarState
    let onSelectionChange: (ViewNode.ID?) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("View Hierarchy")
                .font(.headline)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ZStack {
                List(selection: $viewState.selectedNodeID) {
                    ForEach(visibleNodes, id: \.node.id) { entry in
                        Text(entry.node.displayName)
                            .font(.system(size: 11, design: .monospaced))
                            .padding(.leading, CGFloat(entry.depth) * 12)
                            .tag(entry.node.id)
                    }
                }

                if !viewState.searchText.isEmpty && visibleNodes.isEmpty {
                    Text("No matches")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
            .onChange(of: viewState.selectedNodeID) { id in
                onSelectionChange(id)
            }
            .onChange(of: viewState.searchText) { _ in
                guard let selectedID = viewState.selectedNodeID else { return }
                if !visibleNodes.contains(where: { $0.node.id == selectedID }) {
                    viewState.selectedNodeID = nil
                    onSelectionChange(nil)
                }
            }
        }
        .searchable(text: $viewState.searchText, prompt: "Search (type, identifier, label)")
    }

    private var visibleNodes: [(node: ViewNode, depth: Int)] {
        viewState.visibleNodes(in: hierarchyRoot)
    }
}
