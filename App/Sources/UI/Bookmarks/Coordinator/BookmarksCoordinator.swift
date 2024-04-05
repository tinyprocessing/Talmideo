import Combine
import Foundation

class BookmarksCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: SettingsViewController?

    init?(router: Router) {
        self.router = router
        viewController = SettingsViewController()
        super.init()
    }

    override func start() {
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}
