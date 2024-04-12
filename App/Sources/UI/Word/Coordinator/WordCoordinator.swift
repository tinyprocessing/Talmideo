import Combine
import Foundation

class WordCoordinator: Coordinator<Void> { private let router: Router?
    private var viewController: WordViewController?
    private let database: SQLiteDataDatabase?
    private var id = 0
    private var model: CurrentValueSubject<WordModel, Never> = .init(WordModel())
    private let bookmarks = BookmarkManager()
    private var context: CurrentValueSubject<TalmideoContext, Never>

    init?(router: Router?, databaseWord: SQLiteDataDatabase, context: CurrentValueSubject<TalmideoContext, Never>) {
        self.router = router
        self.context = context
        database = databaseWord
        viewController = WordViewController(model: model)
        super.init()
        viewController?.wordDelegate = self
    }

    private func configure() {
        let query: (String, [Any?]) = database?.query.prepare(.word(value: id)) ?? ("", [])
        if let result = database?.search(query) {
            result.forEach { value in
                if let data = value["data"] as? String {
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            var model = try JSONDecoder().decode(WordModel.self, from: jsonData)
                            model.isBookmarked = bookmarks.isBookmarked(id)
                            self.model.send(model)
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
            }
        }
    }

    override func start() {
        super.start()
    }

    public func update(id: Int) {
        self.id = id
        viewController = WordViewController(model: model)
        viewController?.wordDelegate = self
        router?.navigationController.navigationBar.isHidden = true
        router?.willRouteWith(viewController ?? BaseViewController())
        configure()
    }
}

extension WordCoordinator: WordViewDelegate {
    func close() {
        viewController?.delegate = nil
        viewController = nil
    }

    func bookmark(_ model: WordModel) {
        context.send(.init(state: .bookmarks))
        if bookmarks.isBookmarked(id) {
            bookmarks.removeBookmark(id)
        } else {
            bookmarks.addBookmark(id)
        }
    }
}
