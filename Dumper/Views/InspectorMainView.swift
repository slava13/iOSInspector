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
                        HierarchySidebarView(
                            hierarchyRoot: viewModel.hierarchyRoot,
                            selectedNodeID: $selectedNodeID,
                            searchText: $searchText,
                            onSelectionChange: { id in
                                viewModel.selectedNode = viewModel.node(withID: id)
                            }
                        )
                        .frame(minWidth: 450, maxWidth: 1000)

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

private extension InspectorMainView {
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
