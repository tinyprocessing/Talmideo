import Combine
import Foundation

class SearchCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SearchViewController?
    private let database: SQLiteDataDatabase?
    private var model: CurrentValueSubject<SearchViewModel, Never> = .init(SearchViewModel(result: []))
    private var wordCoordinator: WordCoordinator?

    init?(router: Router) {
        self.router = router
        database = SQLiteDataDatabase(name: Constants.Dictionary,
                                      tableName: Constants.WordDataTable)
        viewController = SearchViewController(model: model)
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
            let words: [SearchWordModel] = result.compactMap { SearchWordModel.from(dictionary: $0) }
            let result = SearchViewModel(result: words)
            model.send(result)
        }
    }

    private func demo() {
        let array = ["happy", "to be", "to work", "love"]
        var result = SearchViewModel(result: [])
        array.forEach { word in
            let query: (String, [Any?]) = database?.query.prepare(.index(
                columns: Config.columns,
                value: word,
                limit: 50
            )) ?? ("", [])
            if let response = database?.search(query) {
                let words: [SearchWordModel] = response.compactMap { SearchWordModel.from(dictionary: $0) }
                words.forEach { value in
                    result.result.append(value)
                }
            }
        }
        model.send(result)
    }

    override func start() {
        wordCoordinator = WordCoordinator(router: router)
        wordCoordinator?.start()
        demo()
        super.start()
    }

    private enum Config {
        static let columns: [String] = ["initial_form", "meaning_ru", "meaning_en"]
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}

extension SearchCoordinator: SearchViewControllerDelegate {
    func searchBar(textDidChange searchText: String) {
        if !searchText.isEmpty { search(searchText) } else {
            demo()
        }
    }

    func didSelectItem(id: Int) {
        wordCoordinator?.update(id: id)
    }

    func close() {}
}
