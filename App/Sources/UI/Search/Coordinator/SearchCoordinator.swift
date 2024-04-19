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
    private let analytics: TalmideoAnalytics

    deinit {
        print(Self.self, "deinit")
    }

    init?(
        router: Router,
        databaseSearch: SQLiteDataDatabase,
        databaseWord: SQLiteDataDatabase,
        context: CurrentValueSubject<TalmideoContext, Never>,
        analytics: TalmideoAnalytics
    ) {
        self.router = router
        self.databaseSearch = databaseSearch
        self.databaseWord = databaseWord
        self.context = context
        self.analytics = analytics
        viewController = SearchViewController(model: model, bookmarks: bookmarks)
        super.init()
        viewController?.searchDelegate = self
    }

    private func search(_ value: String) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            model.send(SearchViewModel(result: []))
            let (isText, array) = isText(value)
            if isText {
                analytics.trackEvent(with: .search, event: .searchText)
                array.forEach { word in
                    let query: (String, [Any?]) = self.databaseSearch.query.prepare(.index(
                        value: word,
                        limit: 1,
                        accurate: true
                    ))
                    let result = self.databaseSearch.search(query)
                    let words = result.compactMap { SearchWordModel.from(dictionary: $0) }
                    var newModel: SearchViewModel = self.model.value
                    newModel.result.append(contentsOf: words)
                    self.model.send(newModel)
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
        analytics.trackEvent(with: .search, event: .search)
    }

    private func isText(_ value: String) -> (Bool, [String]) {
        let array = value.components(separatedBy: " ")
        return (array.count > 1, array)
    }

    private func processSearchResults(isBookmarks: Bool = false, needUpdateModel: Bool = true) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let idArray: [Int] = isBookmarks ? bookmarks.getAllBookmarkedIDs(count: 200) : generateRandomIntegers()
            let searchResultModel = generateSearchResultModel(for: idArray)

            if !isBookmarks {
                generateNotifications()
            } else {
                analytics.trackEvent(with: .search, event: .bookmarks)
            }

            if needUpdateModel {
                updateModel(with: searchResultModel)
            }
        }
    }

    private func generateSearchResultModel(for idArray: [Int]) -> SearchViewModel {
        var searchResultModel = SearchViewModel(result: [])
        for id in idArray {
            let query: (String, [Any?]) = prepareQueryForID(id)
            let response = databaseSearch.search(query)
            let words = response.compactMap { SearchWordModel.fromID(dictionary: $0) }
            searchResultModel.result.append(contentsOf: words)
        }
        return searchResultModel
    }

    private func updateModel(with searchResultModel: SearchViewModel) {
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
        processSearchResults(isBookmarks: true, needUpdateModel: false)
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }

    private func generateNotifications() {
        Task {
            let words = model.value.result.shuffled().prefix(20).map { word in
                LocalNotificationManager.Word(id: "\(word.id)", text: word.form, definition: word.meaning)
            }
            await LocalNotificationManager.shared.scheduleNotifications(words: words)
        }
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
        analytics.trackEvent(with: .bookmarks, event: .bookmarks)
    }

    func close() {
        analytics.trackEvent(with: .search, event: .searchFinish)
    }
}
