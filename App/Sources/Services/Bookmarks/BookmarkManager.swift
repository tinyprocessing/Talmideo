import Foundation

class BookmarkManager {
    private let bookmarkKey = "bookmarkedIDs"
    private var bookmarkedIDs: Set<Int> {
        get {
            return Set(UserDefaults.standard.array(forKey: bookmarkKey) as? [Int] ?? [])
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: bookmarkKey)
        }
    }

    func addBookmark(_ id: Int) {
        var ids = bookmarkedIDs
        ids.insert(id)
        bookmarkedIDs = ids
    }

    func removeBookmark(_ id: Int) {
        var ids = bookmarkedIDs
        ids.remove(id)
        bookmarkedIDs = ids
    }

    func isBookmarked(_ id: Int) -> Bool {
        return bookmarkedIDs.contains(id)
    }

    func getAllBookmarkedIDs() -> [Int] {
        return Array(bookmarkedIDs)
    }
}
