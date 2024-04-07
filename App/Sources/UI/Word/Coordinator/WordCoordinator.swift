import Combine
import Foundation

class WordCoordinator: Coordinator<Void> { private let router: Router?
    private var viewController: WordViewController?
    private let database: SQLiteDataDatabase?
    private var id = 0
    private var model: CurrentValueSubject<WordModel, Never> = .init(WordModel())

    init?(router: Router?) {
        self.router = router
        database = SQLiteDataDatabase(name: Constants.DictionaryTranslator,
                                      tableName: Constants.WordData)
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
                            let model = try JSONDecoder().decode(WordModel.self, from: jsonData)
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
        router?.navigationController.navigationBar.isHidden = true
        router?.willRouteWith(viewController ?? BaseViewController())
        configure()
    }
}

extension WordCoordinator: WordViewDelegate {
    func close() {}
}
