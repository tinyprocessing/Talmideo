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
                                      tableName: Constants.WordDataTable)
        viewController = WordViewController()
        super.init()
    }

    override func start() {
        router?.willRouteWith(viewController ?? BaseViewController())
        router?.navigationController.navigationBar.isHidden = true
        super.start()
    }
}
