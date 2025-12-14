import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct InspectorMainView: View {
    @StateObject private var viewModel: InspectorViewModel
    @State private var isDragging = false
    @State private var droppedURLs: [URL] = []
    @State private var selectedNodeID: ViewNode.ID?
    @State private var searchText = ""

    init() {
        _viewModel = StateObject(wrappedValue: InspectorViewModel())
    }

    init(viewModel: InspectorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                isResetDisabled: viewModel.screenshot == nil
                    && viewModel.hierarchyRoot.isEmpty
                    && viewModel.pendingImageURL == nil
                    && viewModel.pendingHierarchyURL == nil,
                onReset: viewModel.resetState
            )
            Divider()

            Group {
                if viewModel.screenshot == nil {
                    DropZoneView(
                        viewModel: viewModel,
                        isDragging: $isDragging,
                        pendingImageURL: viewModel.pendingImageURL,
                        pendingHierarchyURL: viewModel.pendingHierarchyURL
                    )
                } else {
                    HSplitView {
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
                                viewModel.selectedNode = viewModel.node(withID: id)
                            }
                            .onChange(of: searchText) { _ in
                                guard let selectedID = selectedNodeID else { return }
                                if !visibleNodes.contains(where: { $0.node.id == selectedID }) {
                                    selectedNodeID = nil
                                    viewModel.selectedNode = nil
                                }
                            }
                        }
                        .frame(minWidth: 450, maxWidth: 1000)
                        .searchable(text: $searchText, prompt: "Search (type, identifier, label)")

                        HStack(spacing: 0) {
                            VStack {
                                if viewModel.isLoading {
                                    ProgressView("Loading and Parsing...")
                                } else if let image = viewModel.screenshot {
                                    ScreenshotCanvas(
                                        image: image,
                                        rootNodes: viewModel.hierarchyRoot,
                                        selectedNode: viewModel.selectedNode,
                                        hoveredNode: viewModel.hoveredNode
                                    )
                                }
                            }
                            .frame(minWidth: 500)

                            Divider()

                            NodeDetailView(node: viewModel.selectedNode)
                                .frame(minWidth: 240, maxWidth: 360)
                        }
                    }
                }
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
            return true
        }
        .onChange(of: droppedURLs) { urls in
            processDroppedURLs(urls)
        }
    }
}

private struct ToolbarView: View {
    let isResetDisabled: Bool
    let onReset: () -> Void

    var body: some View {
        HStack {
            Text("Inspector")
                .font(.headline)
            Spacer()
            Button("Reset", action: onReset)
                .disabled(isResetDisabled)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct NodeDetailView: View {
    let node: ViewNode?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            if let node {
                VStack(alignment: .leading, spacing: 8) {
                    detailLine(title: "Element", value: node.type)

                    if let identifier = node.identifier, !identifier.isEmpty {
                        detailLine(title: "Identifier", value: "'\(identifier)'")
                    }

                    if let label = node.label, !label.isEmpty {
                        detailLine(title: "Label", value: "'\(label)'")
                    }

                    detailLine(title: "Frame", value: format(frame: node.frame))

                    if node.isSelected {
                        Text("Selected")
                    }
                }
                .font(.system(size: 12, design: .monospaced))
            } else {
                Text("Select a node to see details.")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .textSelection(.enabled)
    }

    private func detailLine(title: String, value: String) -> some View {
        Text("\(title): \(value)")
    }

    private func format(frame: CGRect) -> String {
        String(
            format: "{{%.1f, %.1f}, {%.1f, %.1f}}",
            Double(frame.origin.x),
            Double(frame.origin.y),
            Double(frame.size.width),
            Double(frame.size.height)
        )
    }
}

private extension InspectorMainView {
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

        return flatten(viewModel.hierarchyRoot, depth: 0)
    }

    func processDroppedURLs(_ urls: [URL]) {
        guard !urls.isEmpty else { return }

        var imageURL = viewModel.pendingImageURL
        var textURL = viewModel.pendingHierarchyURL

        for url in urls {
            let ext = url.pathExtension.lowercased()
            if imageURL == nil && (ext == "png" || ext == "jpg" || ext == "jpeg") {
                imageURL = url
            } else if textURL == nil && (ext == "txt" || ext == "json") {
                textURL = url
            }
        }

        viewModel.pendingImageURL = imageURL
        viewModel.pendingHierarchyURL = textURL

        if let imageURL, let textURL {
            viewModel.loadFiles(imageURL: imageURL, hierarchyURL: textURL)
        } else if viewModel.pendingImageURL == nil && viewModel.pendingHierarchyURL == nil {
            viewModel.errorMessage = "Could not identify a Screenshot (.png/.jpg) or Hierarchy (.txt) file in the dropped items."
        }

        droppedURLs = []
    }

    func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }
                urls.append(url)
            }
        }

        group.notify(queue: .main) {
            droppedURLs = urls
        }
    }
}
