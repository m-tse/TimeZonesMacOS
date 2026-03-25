import SwiftUI

struct ResizeHandle: View {
    @Binding var isDragging: Bool
    let onDrag: (CGFloat) -> Void

    @State private var lastY: CGFloat? = nil

    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.secondary.opacity(isDragging ? 0.6 : 0.3))
                    .frame(width: 36, height: 3)
            )
            .contentShape(Rectangle())
            .cursor(.resizeUpDown)
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        isDragging = true
                        if let last = lastY {
                            let delta = value.location.y - last
                            onDrag(delta)
                        }
                        lastY = value.location.y
                    }
                    .onEnded { _ in
                        isDragging = false
                        lastY = nil
                    }
            )
    }
}

extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        onHover { inside in
            if inside {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

extension CGFloat {
    func clamped(min minVal: CGFloat, max maxVal: CGFloat) -> CGFloat {
        Swift.min(Swift.max(self, minVal), maxVal)
    }
}

extension Double {
    func clamped(min minVal: Double, max maxVal: Double) -> Double {
        Swift.min(Swift.max(self, minVal), maxVal)
    }
}
