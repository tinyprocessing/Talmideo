import Combine
import Foundation
import UIKit

struct TalmideoContext {
    enum State {
        case bookmarks
        case coordinator
    }

    var state: State = .bookmarks

    init(state: State) {
        self.state = state
    }
}

class TalmideoCoordinator: Coordinator<Void> {
    private let router: Router
    private var searchCoordinator: SearchCoordinator?
    private var settingsCoordinator: SettingsCoordinator?
    private var exploreCoordinator: ExploreCoordinator?
    private var onboardingCoordinator: OnboardingCoordinator?
    private let databaseSearch: SQLiteDataDatabase
    private let databaseWord: SQLiteDataDatabase
    private let analytics: TalmideoAnalytics

    private var tabViewController: TabViewController?
    private var context: CurrentValueSubject<TalmideoContext, Never> = .init(TalmideoContext(state: .coordinator))

    deinit {
        print(Self.self, "deinit")
    }

    init?(router: Router) {
        self.router = router
        tabViewController = TabViewController()
        databaseSearch = SQLiteDataDatabase(name: Constants.Dictionary,
                                            tableName: Constants.WordDataTable)
        databaseWord = SQLiteDataDatabase(name: Constants.DictionaryTranslator,
                                          tableName: Constants.WordData)
        analytics = TalmideoAnalytics()
        super.init()
        analytics.trackEvent(with: .app, event: .start)
    }

    private func launchTM() {
        analytics.trackEvent(with: .search, event: .searchStart)
        searchCoordinator = SearchCoordinator(
            router: router,
            databaseSearch: databaseSearch,
            databaseWord: databaseWord,
            context: context,
            analytics: analytics
        )
        settingsCoordinator = SettingsCoordinator(router: router, context: context, analytics: analytics)
        exploreCoordinator = ExploreCoordinator(
            router: router,
            databaseWord: databaseWord,
            context: context,
            analytics: analytics
        )

        searchCoordinator?.start()
        settingsCoordinator?.start()
        exploreCoordinator?.start()

        if let settingsCoordinator = settingsCoordinator {
            addChild(coordinator: settingsCoordinator)
        }
        configureVCs()
    }

    private func configureVCs() {
        var array: [UIViewController] = []
        if let controller = searchCoordinator?.exportViewController() {
            controller.tabBarItem = .init(title: Config.search,
                                          image: Config.imageSearch,
                                          tag: 0)
            array.append(controller)
        }
        if let controller = exploreCoordinator?.exportViewController() {
            controller.tabBarItem = .init(title: Config.explore,
                                          image: Config.imageExplore,
                                          tag: 1)
            array.append(controller)
        }
        if let controller = settingsCoordinator?.exportViewController() {
            controller.tabBarItem = .init(title: Config.settings,
                                          image: Config.imageSettings,
                                          tag: 1)
            array.append(controller)
        }
        tabViewController?.setupTabBarItems(with: array)
        router.willRouteWith(tabViewController!)
        launchOnboarding()
    }

    override func start() {
        super.start()
        launchTM()
    }

    private func launchOnboarding() {
        if !UserDefaults.standard.bool(forKey: "onboardingFinished") {
            onboardingCoordinator = OnboardingCoordinator(router: router)
            onboardingCoordinator?.start()
            if let onboardingCoordinator = onboardingCoordinator {
                router.willRouteWithCover(onboardingCoordinator.exportViewController())
            }
        }
    }

    private enum Config {
        static let search: String = .localized(.search)
        static let settings: String = .localized(.settings)
        static let explore: String = .localized(.explore)
        static var imageSearch: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "magnifyingglass", withConfiguration: config) ?? UIImage()
        }

        static var imageSettings: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "gearshape", withConfiguration: config) ?? UIImage()
        }

        static var imageExplore: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "square.grid.2x2", withConfiguration: config) ?? UIImage()
        }
    }
}
