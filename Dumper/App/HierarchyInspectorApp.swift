import AppKit
import SwiftUI

@main
struct HierarchyInspectorApp: App {
    var body: some Scene {
        WindowGroup {
            InspectorMainView()
                .frame(minWidth: 800, minHeight: 600)
                .background(Color(NSColor.windowBackgroundColor))
        }
    }
}
