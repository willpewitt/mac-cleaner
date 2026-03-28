import Foundation

@Observable class FileReviewModel {
    let files: [URL]
    var currentIndex: Int = 0
    var decisions: [URL: Decision] = [:]

    enum Decision { case keep, delete }

    init(files: [URL]) {
        self.files = files
    }

    var currentFile: URL? {
        guard currentIndex < files.count else { return nil }
        return files[currentIndex]
    }

    var isComplete: Bool { currentIndex >= files.count }

    var filesToDelete: [URL] {
        files.filter { decisions[$0] == .delete }
    }

    func decide(_ decision: Decision) {
        guard let file = currentFile else { return }
        decisions[file] = decision
        currentIndex += 1
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        decisions.removeValue(forKey: files[currentIndex])
    }
}
