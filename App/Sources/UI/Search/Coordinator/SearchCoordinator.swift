import Combine
import Foundation

class SearchCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SearchViewController?
    private let database: SQLiteDataDatabase?
    private var model: CurrentValueSubject<SearchViewModel, Never> = .init(SearchViewModel(result: []))

    init?(router: Router) {
        self.router = router
        database = SQLiteDataDatabase(name: Constants.Dictionary,
                                      tableName: Constants.WordDataTable)
        viewController = SearchViewController(model: model)
        super.init()
        viewController?.searchDelegate = self
    }

    private func search(_ value: String) {
        let query: (String, [Any?]) = database?.query.prepare(.search(
            columns: Config.columns,
            value: value,
            limit: 50
        )) ?? ("", [])
        if let result = database?.search(query) {
            let words: [WordModel] = result.compactMap { WordModel.from(dictionary: $0) }
            let result = SearchViewModel(result: words)
            model.send(result)
        }
    }

    override func start() {
        super.start()
    }

    private enum Config {
        static let columns: [String] = ["meaning_ru", "meaning_en"]
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}

extension SearchCoordinator: SearchViewControllerDelegate {
    func searchBar(textDidChange searchText: String) {
        if !searchText.isEmpty { search(searchText) } else {
            model.send(SearchViewModel(result: []))
        }
    }
}
