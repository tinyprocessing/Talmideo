import Combine
import Foundation

class SearchCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SearchViewController?
    private let database: SQLiteDataDatabase?
    private var model: CurrentValueSubject<SearchViewModel, Never> = .init(SearchViewModel(result: []))
    private var wordCoordinator: WordCoordinator?
    private let bookmarks = BookmarkManager()

    init?(router: Router) {
        self.router = router
        database = SQLiteDataDatabase(name: Constants.Dictionary,
                                      tableName: Constants.WordDataTable)
        viewController = SearchViewController(model: model, bookmarks: bookmarks)
        super.init()
        viewController?.searchDelegate = self
    }

    private func search(_ value: String) {
        let query: (String, [Any?]) = database?.query.prepare(.index(
            columns: Config.columns,
            value: value,
            limit: 50
        )) ?? ("", [])
        if let result = database?.search(query) {
            let words = result.compactMap { SearchWordModel.from(dictionary: $0) }
            let viewModel = SearchViewModel(result: Array(Set(words)))
            model.send(viewModel)
        }
    }

    private func processSearchResults(isBookmarks: Bool = false) {
//        let idArray: [Int] = isBookmarks ?
//            (bookmarks.getAllBookmarkedIDs().isEmpty ? generateRandomIntegers() : bookmarks.getAllBookmarkedIDs()) :
//            generateRandomIntegers()
        let idArray: [Int] = generateRandomIntegers()

        var searchResultModel = SearchViewModel(result: [])

        idArray.forEach { id in
            let query: (String, [Any?]) = prepareQueryForID(id)

            if let response = database?.search(query) {
                let words = response.compactMap { SearchWordModel.from(dictionary: $0) }
                Array(Set(words)).forEach { word in
                    searchResultModel.result.append(word)
                }
            }
        }

        model.send(searchResultModel)
    }

    private func prepareQueryForID(_ id: Int) -> (String, [Any?]) {
        return database?.query.prepare(.id(
            value: "\(id)",
            limit: 50
        )) ?? ("", [])
    }

    override func start() {
        wordCoordinator = WordCoordinator(router: router)
        wordCoordinator?.start()
        processSearchResults(isBookmarks: true)
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
            processSearchResults(isBookmarks: true)
        }
    }

    func didSelectItem(id: Int) {
        wordCoordinator?.update(id: id)
    }

    func close() {}
}
