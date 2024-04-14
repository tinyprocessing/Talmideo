import Combine
import Foundation

class OnboardingCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: OnboardingViewController

    init?(
        router: Router
    ) {
        self.router = router
        viewController = OnboardingViewController()
        super.init()
    }

    override func start() {
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController
    }
}
