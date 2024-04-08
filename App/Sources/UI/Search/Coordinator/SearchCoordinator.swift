import Combine
import Foundation

class SearchCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SearchViewController?
    private let databaseSearch: SQLiteDataDatabase
    private let databaseWord: SQLiteDataDatabase
    private var model: CurrentValueSubject<SearchViewModel, Never> = .init(SearchViewModel(result: []))
    private var wordCoordinator: WordCoordinator?
    private let bookmarks = BookmarkManager()
    private var bookmarksFilter = false

    init?(router: Router, databaseSearch: SQLiteDataDatabase, databaseWord: SQLiteDataDatabase) {
        self.router = router
        self.databaseSearch = databaseSearch
        self.databaseWord = databaseWord
        viewController = SearchViewController(model: model, bookmarks: bookmarks)
        super.init()
        viewController?.searchDelegate = self
    }

    private func search(_ value: String) {
        let query: (String, [Any?]) = databaseSearch.query.prepare(.index(
            value: value,
            limit: 50
        ))
        let result = databaseSearch.search(query)
        let words = result.compactMap { SearchWordModel.from(dictionary: $0) }
        let viewModel = SearchViewModel(result: words)
        model.send(viewModel)
    }

    private func processSearchResults(isBookmarks: Bool = false) {
        let idArray: [Int] = isBookmarks ? bookmarks.getAllBookmarkedIDs() : generateRandomIntegers()

        var searchResultModel = SearchViewModel(result: [])

        idArray.forEach { id in
            let query: (String, [Any?]) = prepareQueryForID(id)

            let response = databaseSearch.search(query)
            let words = response.compactMap { SearchWordModel.from(dictionary: $0) }
            Array(Set(words)).forEach { word in
                searchResultModel.result.append(word)
            }
        }

        model.send(searchResultModel)
    }

    private func prepareQueryForID(_ id: Int) -> (String, [Any?]) {
        return databaseSearch.query.prepare(.id(
            value: "\(id)",
            limit: 50
        ))
    }

    override func start() {
        wordCoordinator = WordCoordinator(router: router, databaseWord: databaseWord)
        wordCoordinator?.start()
        processSearchResults(isBookmarks: bookmarksFilter)
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }

    private func generateRandomIntegers() -> [Int] {
        var randomIntegers = [Int]()
        for _ in 0..<20 {
            let randomInt = Int.random(in: 0...9142)
            randomIntegers.append(randomInt)
        }
        return randomIntegers
    }

    private enum Config {
        static let columns: [String] = ["initial_form", "meaning_ru", "meaning_en"]
    }
}

extension SearchCoordinator: SearchViewControllerDelegate {
    func searchBar(textDidChange searchText: String) {
        if !searchText.isEmpty { search(searchText) } else {
            processSearchResults(isBookmarks: bookmarksFilter)
        }
    }

    func didSelectItem(id: Int) {
        wordCoordinator?.update(id: id)
    }

    func bookmarkTap(isOn: Bool) {
        bookmarksFilter = isOn
        processSearchResults(isBookmarks: isOn)
    }

    func close() {}
}
