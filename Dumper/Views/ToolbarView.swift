import SwiftUI

struct ToolbarView: View {
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
