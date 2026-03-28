import SwiftUI

struct DirectoryPickerView: View {
    let onFilesSelected: ([URL]) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 72))
                .foregroundStyle(.tint)

            Text("Mac Cleaner")
                .font(.largeTitle.bold())

            Text("Pick a folder and review files one-by-one.\nPress  k  to keep or  d  to delete.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Open Folder…") {
                pickFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(48)
    }

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        panel.message = "Choose a folder to review"
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let keys: [URLResourceKey] = [.isRegularFileKey, .isPackageKey]
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ))?.filter {
            let values = try? $0.resourceValues(forKeys: Set(keys))
            return values?.isRegularFile == true || values?.isPackage == true
        } ?? []

        guard !urls.isEmpty else { return }
        onFilesSelected(
            urls.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        )
    }
}
