import Foundation

struct DeletionService {
    func moveToTrash(_ urls: [URL]) throws {
        for url in urls {
            try FileManager.default.trashItem(at: url, resultingItemURL: nil)
        }
    }

    func deletePermanently(_ urls: [URL]) throws {
        for url in urls {
            try FileManager.default.removeItem(at: url)
        }
    }
}
