# Dumper (Native iOS Hierarchy Inspector)

macOS utility to visualize iOS view hierarchies from a screenshot and a debug description dump. Drag in a screenshot (.png/.jpg) and the matching hierarchy text (.txt/.json) to explore the tree and highlight elements on the image.

## Features
- Drag-and-drop workflow; accepts files one at a time or together.
- Parses `app.debugDescription` output into a navigable hierarchy.
- Highlights selected nodes on top of the screenshot with scaled coordinates.
- Shows which dropped file is still pending, with filenames and icons.
- Reset button to clear state at any point.

## Getting Started
1. Open `Dumper.xcodeproj` in Xcode (macOS target).
2. Build and run the `Dumper` app.
3. Drag a screenshot (.png/.jpg) and the hierarchy dump (.txt/.json) onto the window (order doesn’t matter). Once both are present, the view loads automatically.

### Expected Inputs
- **Screenshot:** A screen capture of the UI you are inspecting.
- **Hierarchy dump:** The text output from `app.debugDescription` (or similar) that contains lines like `{{x, y}, {w, h}}` plus `label`/`identifier` metadata.

## Project Structure
- `Dumper/App` — App entry (`HierarchyInspectorApp`).
- `Dumper/Models` — Core data types (`ViewNode`).
- `Dumper/Services` — Parsing and IO (`HierarchyParser`, `SnapshotLoader`).
- `Dumper/ViewModels` — UI state (`InspectorViewModel`).
- `Dumper/Views` — SwiftUI views (`InspectorMainView`, `DropZoneView`, `ScreenshotCanvas`).

## How It Works
1. **Load:** `SnapshotLoader` reads the screenshot and hierarchy text (async).
2. **Parse:** `HierarchyParser` converts each line into `ViewNode` with a `CGRect` frame and optional `label`/`identifier`.
3. **Bind:** `InspectorViewModel` stores the tree, image, selection, and pending drops.
4. **Render:** `InspectorMainView` shows the tree (flattened, fully expanded) and `ScreenshotCanvas` overlays selection highlights scaled to the displayed image.

## Reset & Pending State
- The toolbar Reset clears loaded and pending files.
- Drop either file first; the UI shows what’s accepted and what’s still needed.

## Notes
- Coordinates are taken directly from the hierarchy dump and scaled to the displayed image size; ensure screenshot and dump are from the same UI state.
- If parsing fails, check that the dump contains frame data in `{{x, y}, {w, h}}` format.
