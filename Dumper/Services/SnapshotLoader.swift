import AppKit
import Foundation

struct InspectorSnapshot {
    let screenshot: NSImage
    let hierarchy: [ViewNode]
}

enum SnapshotLoaderError: LocalizedError {
    case imageLoadFailed(filename: String)
    case hierarchyLoadFailed(filename: String)

    var errorDescription: String? {
        switch self {
        case let .imageLoadFailed(filename):
            return "Failed to load screenshot from \(filename)"
        case let .hierarchyLoadFailed(filename):
            return "Failed to load hierarchy text from \(filename)"
        }
    }
}

protocol SnapshotLoading {
    func load(imageURL: URL, hierarchyURL: URL, completion: @escaping (Result<InspectorSnapshot, SnapshotLoaderError>) -> Void)
}

final class SnapshotLoader: SnapshotLoading {
    private let parser: HierarchyParsing
    private let queue: DispatchQueue

    init(
        parser: HierarchyParsing = HierarchyParser(),
        queue: DispatchQueue = DispatchQueue(label: "com.dumper.snapshotLoader", qos: .userInitiated)
    ) {
        self.parser = parser
        self.queue = queue
    }

    func load(imageURL: URL, hierarchyURL: URL, completion: @escaping (Result<InspectorSnapshot, SnapshotLoaderError>) -> Void) {
        queue.async { [parser] in
            guard let image = NSImage(contentsOf: imageURL) else {
                DispatchQueue.main.async {
                    completion(.failure(.imageLoadFailed(filename: imageURL.lastPathComponent)))
                }
                return
            }

            guard let hierarchyText = try? String(contentsOf: hierarchyURL) else {
                DispatchQueue.main.async {
                    completion(.failure(.hierarchyLoadFailed(filename: hierarchyURL.lastPathComponent)))
                }
                return
            }

            let nodes = parser.parse(content: hierarchyText)
            let snapshot = InspectorSnapshot(screenshot: image, hierarchy: nodes)

            DispatchQueue.main.async {
                completion(.success(snapshot))
            }
        }
    }
}
