import UIKit

class Router {
    let baseRoute: RouteType = .home
    let navigationController = UINavigationController()

    init(baseRoute: RouteType) {
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: Colors.BackgroundColor
        ]
    }

    private func viewControllerFor(route routeType: RouteType) -> BaseViewController {
        var controller: BaseViewController!
        switch routeType {
        case .home:
            controller = BaseViewController()
        }
        controller.delegate = self
        return controller
    }
}

extension Router: BaseViewControllerDelegate {
    func willRouteTo(_ routeType: RouteType) {
        let vc = viewControllerFor(route: routeType)
        navigationController.pushViewController(vc, animated: true)
    }

    func willRouteWith(_ vc: UIViewController) {
        navigationController.pushViewController(vc, animated: true)
    }
}
