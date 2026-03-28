import SwiftUI
import QuickLookUI

struct FileReviewView: View {
    let model: FileReviewModel
    let onComplete: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            progressBar

            if let file = model.currentFile {
                fileHeader(file)
                ZStack {
                    // Invisible pre-loader warms the QL daemon cache for the next file
                    // so it renders quickly when the user navigates to it.
                    if let next = nextQLURL {
                        QLPreloadView(url: next)
                            .opacity(0.001)
                            .allowsHitTesting(false)
                    }
                    FilePreviewView(url: file)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                keyHints
            }
        }
        .focusable()
        .focused($focused)
        .onKeyPress("k") {
            advance(decision: .keep)
            return .handled
        }
        .onKeyPress("d") {
            advance(decision: .delete)
            return .handled
        }
        .onKeyPress("b") {
            model.goBack()
            return .handled
        }
        .onAppear { focused = true }
    }

    // Only pre-load QL for non-package files (packages render instantly from icon)
    private var nextQLURL: URL? {
        let nextIndex = model.currentIndex + 1
        guard nextIndex < model.files.count else { return nil }
        let url = model.files[nextIndex]
        let isPackage = (try? url.resourceValues(forKeys: [.isPackageKey]).isPackage) == true
        return isPackage ? nil : url
    }

    private var progressBar: some View {
        ProgressView(value: Double(model.currentIndex), total: Double(model.files.count))
            .padding(.horizontal)
            .padding(.top, 12)
    }

    private func fileHeader(_ file: URL) -> some View {
        HStack {
            Text(file.lastPathComponent)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text("\(model.currentIndex + 1) / \(model.files.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var keyHints: some View {
        HStack {
            keyHint(key: "k", label: "Keep", color: .green)
            Spacer()
            keyHint(key: "b", label: "Back", color: .secondary)
            Spacer()
            keyHint(key: "d", label: "Delete", color: .red)
        }
        .padding()
    }

    private func keyHint(key: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Text(key)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
            Text(label)
                .foregroundStyle(color)
        }
    }

    private func advance(decision: FileReviewModel.Decision) {
        model.decide(decision)
        if model.isComplete { onComplete() }
    }
}

// MARK: - Hidden pre-loader

private struct QLPreloadView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal)!
        view.autostarts = true
        view.previewItem = url as NSURL
        return view
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        nsView.previewItem = url as NSURL
    }
}
