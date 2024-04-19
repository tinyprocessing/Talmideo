import Combine
import Foundation

class ExploreCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: ExploreViewController?
    private let database: SQLiteDataDatabase
    private let bookmarksManager = BookmarkManager()
    private var context: CurrentValueSubject<TalmideoContext, Never>
    private var cancellables = Set<AnyCancellable>()
    private let analytics: TalmideoAnalytics

    private var nouns: [Int] = []
    private var verbs: [Int] = []
    private var adjectives: [Int] = []
    private var bookmarks: [Int] = []

    public enum ExploreIndex: String {
        case noun = "N"
        case verb = "V"
        case adjective = "A"
        case bookmarks

        var value: String {
            return #""part_of_speech":"\#(rawValue)""#
        }
    }

    deinit {
        print(Self.self, "deinit")
    }

    init?(
        router: Router,
        databaseWord: SQLiteDataDatabase,
        context: CurrentValueSubject<TalmideoContext, Never>,
        analtyics: TalmideoAnalytics
    ) {
        self.router = router
        self.context = context
        analytics = analytics
        database = databaseWord
        viewController = ExploreViewController(context: context)
        super.init()
        viewController?.exploreDelegate = self
    }

    override func start() {
        super.start()

        context
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                prepare()
                viewController?.updateBookmarks()
            }
            .store(in: &cancellables)
    }

    private func prepare() {
        Task {
            let array: [ExploreIndex] = [.noun, .verb, .adjective, .bookmarks]
            for value in array {
                await load(value)
            }
        }
    }

    private func load(_ value: ExploreIndex) async {
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
        case .bookmarks:
            bookmarks = bookmarksManager.getAllBookmarkedIDs()
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
        case .bookmarks:
            wordsArray = bookmarks
        }

        let cardCoordinator = createCardCoordinator(withWords: wordsArray)
        cardCoordinator?.start()
        if let viewController = cardCoordinator?.exportViewController() {
            router?.willRouteWith(viewController)
        }
    }

    private func createCardCoordinator(withWords words: [Int]) -> CardCoordinator? {
        return CardCoordinator(router: router, databaseWord: database, words: words, analytics: analytics)
    }
}
