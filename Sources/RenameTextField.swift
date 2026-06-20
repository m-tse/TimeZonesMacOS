import SwiftUI
import AppKit

/// An NSTextField subclass that grabs focus and selects all its text the instant
/// it is attached to a window. Using `viewDidMoveToWindow` (rather than a timer or
/// SwiftUI `@FocusState`) means the selection happens at exactly the moment the
/// field exists in the window hierarchy — no race, no polling. This is how AppKit
/// rename-in-place fields (e.g. Finder) reliably highlight their text.
final class AutoSelectTextField: NSTextField {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        // selectText makes us the first responder AND selects all text.
        selectText(nil)
        // If the window wasn't key yet (e.g. just after a context menu closed),
        // currentEditor() is nil — retry once on the next runloop.
        if currentEditor() == nil {
            DispatchQueue.main.async { [weak self] in
                guard let self, self.window != nil else { return }
                self.selectText(nil)
            }
        }
    }
}

/// A SwiftUI wrapper around `AutoSelectTextField` for editing a timezone label
/// inline. Commits on Return or focus loss, cancels on Escape.
struct RenameTextField: NSViewRepresentable {
    @Binding var text: String
    var isBold: Bool
    var onCommit: () -> Void
    var onCancel: () -> Void

    func makeNSView(context: Context) -> AutoSelectTextField {
        let field = AutoSelectTextField(string: text)
        field.delegate = context.coordinator
        field.font = NSFont.systemFont(ofSize: 15, weight: isBold ? .bold : .medium)
        field.isBordered = true
        field.bezelStyle = .roundedBezel
        field.focusRingType = .default
        field.lineBreakMode = .byTruncatingTail
        field.usesSingleLineMode = true
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return field
    }

    func updateNSView(_ nsView: AutoSelectTextField, context: Context) {
        context.coordinator.parent = self
        // Only mutate the field when something actually changed. Re-assigning
        // stringValue or font on an actively-edited NSTextField resets its field
        // editor and wipes the text selection — and this view re-renders every
        // second from the app's clock timer.
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
        let newFont = NSFont.systemFont(ofSize: 15, weight: isBold ? .bold : .medium)
        if nsView.font != newFont {
            nsView.font = newFont
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: RenameTextField
        private var finished = false

        init(_ parent: RenameTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            parent.text = field.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                finish { parent.onCommit() }
                return true
            }
            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                finish { parent.onCancel() }
                return true
            }
            return false
        }

        // Clicking away from the field commits the edit.
        func controlTextDidEndEditing(_ obj: Notification) {
            finish { parent.onCommit() }
        }

        private func finish(_ action: () -> Void) {
            guard !finished else { return }
            finished = true
            action()
        }
    }
}
