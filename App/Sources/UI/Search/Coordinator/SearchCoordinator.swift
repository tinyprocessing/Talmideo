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
    private var context: CurrentValueSubject<TalmideoContext, Never>

    deinit {
        print(Self.self, "deinit")
    }

    init?(
        router: Router,
        databaseSearch: SQLiteDataDatabase,
        databaseWord: SQLiteDataDatabase,
        context: CurrentValueSubject<TalmideoContext, Never>
    ) {
        self.router = router
        self.databaseSearch = databaseSearch
        self.databaseWord = databaseWord
        self.context = context
        viewController = SearchViewController(model: model, bookmarks: bookmarks)
        super.init()
        viewController?.searchDelegate = self
    }

    private func search(_ value: String) {
        let (isText, array) = isText(value)
        if isText {
            model.send(SearchViewModel(result: []))
            print(array)
            array.forEach { word in
                let query: (String, [Any?]) = databaseSearch.query.prepare(.index(
                    value: word,
                    limit: 1,
                    accurate: true
                ))
                let result = databaseSearch.search(query)
                let words = result.compactMap { SearchWordModel.from(dictionary: $0) }
                var newModel: SearchViewModel = model.value
                newModel.result.append(contentsOf: words)
                model.send(newModel)
            }
        } else {
            let query: (String, [Any?]) = databaseSearch.query.prepare(.index(
                value: value,
                limit: 50,
                accurate: false
            ))
            let result = databaseSearch.search(query)
            let words = result.compactMap { SearchWordModel.from(dictionary: $0) }
            let viewModel = SearchViewModel(result: words)
            model.send(viewModel)
        }
    }

    private func isText(_ value: String) -> (Bool, [String]) {
        let array = value.components(separatedBy: " ")
        return (array.count > 1, array)
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
        wordCoordinator = WordCoordinator(router: router, databaseWord: databaseWord, context: context)
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

    private enum Config {}
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
