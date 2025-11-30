import AppKit
import SwiftUI

struct ScreenshotCanvas: View {
    let image: NSImage
    let rootNodes: [ViewNode]
    let selectedNode: ViewNode?
    let hoveredNode: ViewNode?

    var body: some View {
        GeometryReader { geometry in
            let scaleResult = calculateScale(containerSize: geometry.size, imageSize: image.size)

            ZStack(alignment: .topLeading) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: scaleResult.drawSize.width, height: scaleResult.drawSize.height)

                ForEach([hoveredNode].compactMap { $0 }, id: \.id) { node in
                    overlay(for: node, scaleFactor: scaleResult.scaleFactor, isHover: true)
                }
                ForEach([selectedNode].compactMap { $0 }, id: \.id) { node in
                    overlay(for: node, scaleFactor: scaleResult.scaleFactor, isHover: false)
                }
            }
            .frame(width: scaleResult.drawSize.width, height: scaleResult.drawSize.height)
            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
        }
    }

    @ViewBuilder
    private func overlay(for node: ViewNode, scaleFactor: CGFloat, isHover: Bool) -> some View {
        Rectangle()
            .stroke(isHover ? Color.yellow.opacity(0.8) : Color.red, lineWidth: isHover ? 2 : 3)
            .background(Color.red.opacity(isHover ? 0.1 : 0.3))
            .frame(
                width: node.frame.width * scaleFactor,
                height: node.frame.height * scaleFactor
            )
            .position(
                x: node.frame.midX * scaleFactor,
                y: node.frame.midY * scaleFactor
            )
            .allowsHitTesting(false)
    }

    private func calculateScale(containerSize: CGSize, imageSize: CGSize) -> (drawSize: CGSize, scaleFactor: CGFloat) {
        let widthRatio = containerSize.width / imageSize.width
        let heightRatio = containerSize.height / imageSize.height
        let fitScale = min(widthRatio, heightRatio)

        let drawWidth = imageSize.width * fitScale
        let drawHeight = imageSize.height * fitScale

        let logicalWidth: CGFloat
        if let root = rootNodes.first, root.frame.width > 0 {
            logicalWidth = root.frame.width
        } else {
            logicalWidth = 390.0
        }

        let finalScale = drawWidth / logicalWidth

        return (CGSize(width: drawWidth, height: drawHeight), finalScale)
    }
}
