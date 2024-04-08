import Foundation

class BookmarkManager {
    private let bookmarkKey = "bookmarkedIDs"

    private var bookmarkedIDs: [Int: Date] {
        get {
            guard let data = UserDefaults.standard.data(forKey: bookmarkKey) else { return [:] }
            return (try? JSONDecoder().decode([Int: Date].self, from: data)) ?? [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: bookmarkKey)
            }
        }
    }

    func addBookmark(_ id: Int) {
        var ids = bookmarkedIDs
        ids[id] = Date()
        bookmarkedIDs = ids
    }

    func removeBookmark(_ id: Int) {
        var ids = bookmarkedIDs
        ids.removeValue(forKey: id)
        bookmarkedIDs = ids
    }

    func isBookmarked(_ id: Int) -> Bool {
        return bookmarkedIDs.keys.contains(id)
    }

    func getAllBookmarkedIDs() -> [Int] {
        let sortedIDs = bookmarkedIDs.sorted(by: { $0.value > $1.value })
        let limitedIDs = Array(sortedIDs.prefix(100))
        return limitedIDs.map { $0.key }
    }
}
