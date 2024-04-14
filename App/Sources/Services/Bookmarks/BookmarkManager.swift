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

    public var count: Int {
        return getAllBookmarkedIDs().count
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

    func getAllBookmarkedIDs(count: Int? = nil) -> [Int] {
        let stored = bookmarkedIDs.sorted(by: { $0.value > $1.value })

        if let count = count {
            let limited = Array(stored.prefix(count))
            return limited.map { $0.key }
        } else {
            return stored.map { $0.key }
        }
    }

    func removeAll() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
    }
}
