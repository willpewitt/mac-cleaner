import SwiftUI

struct SummaryView: View {
    let model: FileReviewModel
    let onStartOver: () -> Void

    @State private var deletionMode: DeletionMode = .trash
    @State private var deletionError: String?
    @State private var isDone = false

    enum DeletionMode { case trash, permanent }

    private var toDelete: [URL] { model.filesToDelete }

    var body: some View {
        VStack(spacing: 20) {
            Text("Review Complete")
                .font(.largeTitle.bold())
                .padding(.top)

            if isDone {
                doneView
            } else if toDelete.isEmpty {
                emptyView
            } else {
                deletionView
            }

            Spacer()

            Button("Start Over", action: onStartOver)
                .padding(.bottom)
        }
        .padding(.horizontal)
    }

    private var doneView: some View {
        Label(
            "Files have been \(deletionMode == .trash ? "moved to Trash" : "permanently deleted").",
            systemImage: "checkmark.circle.fill"
        )
        .font(.title3)
        .foregroundStyle(.green)
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("No files marked for deletion.")
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var deletionView: some View {
        VStack(spacing: 16) {
            Text("\(toDelete.count) file\(toDelete.count == 1 ? "" : "s") marked for deletion")
                .font(.headline)

            List(toDelete, id: \.self) { url in
                Label(url.lastPathComponent, systemImage: "trash")
                    .lineLimit(1)
            }
            .frame(maxHeight: 240)

            Picker("Method", selection: $deletionMode) {
                Text("Move to Trash").tag(DeletionMode.trash)
                Text("Delete Permanently").tag(DeletionMode.permanent)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            if deletionMode == .permanent {
                Label("This cannot be undone.", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if let error = deletionError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Confirm Deletion") {
                confirmDeletion()
            }
            .buttonStyle(.borderedProminent)
            .tint(deletionMode == .permanent ? .red : nil)
        }
    }

    private func confirmDeletion() {
        do {
            let service = DeletionService()
            switch deletionMode {
            case .trash:
                try service.moveToTrash(toDelete)
            case .permanent:
                try service.deletePermanently(toDelete)
            }
            isDone = true
            deletionError = nil
        } catch {
            deletionError = error.localizedDescription
        }
    }
}
