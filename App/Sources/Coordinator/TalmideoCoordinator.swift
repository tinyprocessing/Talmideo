import Foundation

class TalmideoCoordinator: Coordinator<Void> {
    private let router: Router
    private var searchCoordinator: SearchCoordinator?

    init?(router: Router) {
        self.router = router
        super.init()
    }

    private func launchTM() {
        let coordinator = SearchCoordinator(router: router)
        coordinator?.start()
        searchCoordinator = coordinator
    }

    override func start() {
        super.start()
        launchTM()
    }
}
