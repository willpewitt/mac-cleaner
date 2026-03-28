import SwiftUI
import QuickLookUI

struct FilePreviewView: View {
    let url: URL

    var body: some View {
        if isPackage {
            PackagePreviewView(url: url)
        } else {
            QLPreviewRepresentable(url: url)
        }
    }

    private var isPackage: Bool {
        (try? url.resourceValues(forKeys: [.isPackageKey]).isPackage) == true
    }
}

// MARK: - Package preview (apps, pkg installers, frameworks, etc.)
	
private struct PackagePreviewView: View {
    let url: URL

    private var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path(percentEncoded: false))
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(nsImage: icon)
                .resizable()
                .interpolation(.high)
                .frame(width: 128, height: 128)

            Text(url.deletingPathExtension().lastPathComponent)
                .font(.title2.bold())

            if !url.pathExtension.isEmpty {
                Text(url.pathExtension.uppercased())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.quaternary, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - QuickLook preview (documents, images, PDFs, etc.)

private struct QLPreviewRepresentable: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal)!
        view.autostarts = true
        return view
    }

    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        nsView.previewItem = url as NSURL
    }
}
