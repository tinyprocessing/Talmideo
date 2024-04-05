import Combine
import Foundation

class WordCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: WordViewController?
    private let database: SQLiteDataDatabase?
    private let id: Int

    init?(router: Router?, id: Int) {
        self.router = router
        self.id = id
        database = SQLiteDataDatabase(name: Constants.DictionaryTranslator,
                                      tableName: Constants.WordData)
        viewController = WordViewController()
        super.init()
        configure()
    }

    private func configure() {
        let query: (String, [Any?]) = database?.query.prepare(.word(value: id)) ?? ("", [])
        if let result = database?.search(query) {
            result.forEach { value in
                if let data = value["data"] as? String {
                    if let jsonData = data.data(using: .utf8) {
                        do {
                            let wordModel = try JSONDecoder().decode(WordModel.self, from: jsonData)
                            print(wordModel)
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
            }
        }
    }

    override func start() {
        router?.willRouteWith(viewController ?? BaseViewController())
        router?.navigationController.navigationBar.isHidden = true
        super.start()
    }
}
