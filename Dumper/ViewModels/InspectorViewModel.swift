import AppKit
import Foundation

@MainActor
final class InspectorViewModel: ObservableObject {
    @Published var hierarchyRoot: [ViewNode] = []
    @Published var screenshot: NSImage?
    @Published var selectedNode: ViewNode?
    @Published var hoveredNode: ViewNode?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var pendingImageURL: URL?
    @Published var pendingHierarchyURL: URL?

    private let snapshotLoader: SnapshotLoading

    init(snapshotLoader: SnapshotLoading = SnapshotLoader()) {
        self.snapshotLoader = snapshotLoader
    }

    func loadFiles(imageURL: URL, hierarchyURL: URL) {
        isLoading = true
        errorMessage = nil
        pendingImageURL = nil
        pendingHierarchyURL = nil

        snapshotLoader.load(imageURL: imageURL, hierarchyURL: hierarchyURL) { [weak self] result in
            guard let self else { return }
            self.apply(result: result)
        }
    }

    func resetState() {
        hierarchyRoot = []
        screenshot = nil
        selectedNode = nil
        hoveredNode = nil
        errorMessage = nil
        isLoading = false
        pendingImageURL = nil
        pendingHierarchyURL = nil
    }

    func node(withID id: ViewNode.ID?) -> ViewNode? {
        guard let id else { return nil }
        return findNode(in: hierarchyRoot, id: id)
    }

    private func apply(result: Result<InspectorSnapshot, SnapshotLoaderError>) {
        switch result {
        case let .success(snapshot):
            screenshot = snapshot.screenshot
            hierarchyRoot = snapshot.hierarchy
            isLoading = false
        case let .failure(error):
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func findNode(in nodes: [ViewNode], id: ViewNode.ID) -> ViewNode? {
        for node in nodes {
            if node.id == id {
                return node
            }
            if let found = findNode(in: node.children, id: id) {
                return found
            }
        }
        return nil
    }
}
