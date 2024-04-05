import Foundation
import UIKit

class TalmideoCoordinator: Coordinator<Void> {
    private let router: Router
    private var searchCoordinator: SearchCoordinator?
    private var settingsCoordinator: SettingsCoordinator?
    private var bookmarksCoordinator: BookmarksCoordinator?

    private var tabViewController: TabViewController?

    init?(router: Router) {
        self.router = router
        tabViewController = TabViewController()
        super.init()
    }

    private func launchTM() {
        searchCoordinator = SearchCoordinator(router: router)
        settingsCoordinator = SettingsCoordinator(router: router)
        bookmarksCoordinator = BookmarksCoordinator(router: router)

        searchCoordinator?.start()
        settingsCoordinator?.start()
        bookmarksCoordinator?.start()

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
        if let controller = bookmarksCoordinator?.exportViewController() {
            controller.tabBarItem = .init(title: Config.bookmarks,
                                          image: Config.imageBookmarks,
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
    }

    override func start() {
        super.start()
        launchTM()
    }

    private enum Config {
        static let search = "Search"
        static let settings = "Settings"
        static let bookmarks = "Bookmarks"
        static var imageSearch: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "magnifyingglass", withConfiguration: config) ?? UIImage()
        }

        static var imageSettings: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "gearshape", withConfiguration: config) ?? UIImage()
        }

        static var imageBookmarks: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
            return UIImage(systemName: "book", withConfiguration: config) ?? UIImage()
        }
    }
}
