import Combine
import Foundation

class ExploreCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: ExploreViewController?

    init?(router: Router) {
        self.router = router
        viewController = ExploreViewController()
        super.init()
    }

    override func start() {
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}
