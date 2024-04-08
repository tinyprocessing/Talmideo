import Combine
import Foundation

class ExploreCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: ExploreViewController?
    private let database: SQLiteDataDatabase

    private var nouns: [Int] = []
    private var verbs: [Int] = []
    private var adjectives: [Int] = []

    init?(router: Router, databaseWord: SQLiteDataDatabase) {
        self.router = router
        database = databaseWord
        viewController = ExploreViewController()
        super.init()
        viewController?.exploreDelegate = self
    }

    override func start() {
        let array: [ExploreIndex] = [.noun, .verb, .adjective]
        array.forEach { value in
            load(value)
        }
        super.start()
    }

    public enum ExploreIndex: String {
        case noun = "N"
        case verb = "V"
        case adjective = "A"

        var value: String {
            return #""part_of_speech":"\#(rawValue)""#
        }
    }

    private func load(_ value: ExploreIndex) {
        let query: (String, [Any?]) = database.query.prepare(.export(value: value.value))
        let result = database.search(query)
        var ids: [Int] = []
        result.forEach { element in
            element.forEach { keyValuePair in
                if keyValuePair.key == "id", let id = keyValuePair.value as? Int {
                    ids.append(id)
                }
            }
        }
        switch value {
        case .noun:
            nouns = ids
        case .verb:
            verbs = ids
        case .adjective:
            adjectives = ids
        }
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}

extension ExploreCoordinator: ExploreViewControllerDelegate {
    func didTap(model: ExploreItemView.ExploreItemModel) {
        var wordsArray: [Int] = []
        switch model.type {
        case .noun:
            wordsArray = nouns
        case .verb:
            wordsArray = verbs
        case .adjective:
            wordsArray = adjectives
        }

        let cardCoordinator = createCardCoordinator(withWords: wordsArray)
        cardCoordinator?.start()
        if let viewController = cardCoordinator?.exportViewController() {
            router?.willRouteWith(viewController)
        }
    }

    private func createCardCoordinator(withWords words: [Int]) -> CardCoordinator? {
        return CardCoordinator(router: router, databaseWord: database, words: words)
    }
}
