import UIKit

class Router {
    let baseRoute: RouteType = .home
    let navigationController = UINavigationController()

    init(baseRoute: RouteType) {
        navigationController.navigationBar.isHidden = true
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

    func willRouteWithCover(_ vc: UIViewController) {
        vc.modalPresentationStyle = .overFullScreen
        navigationController.present(vc, animated: false)
    }

    // viewController.modalPresentationStyle = .overFullScreen
    // viewController.delegate = self
    // viewController.productContext = productContext
    // viewController.container = container
    // navigationControllerOpticalVTO = UINavigationController(rootViewController: UIViewController())
    // if let navigationControllerOpticalVTO {
    //    navigationControllerOpticalVTO.interactivePopGestureRecognizer?.isEnabled = false
    //    navigationControllerOpticalVTO.modalPresentationStyle = .overFullScreen
    //    let presentingController = navigationController.presentedViewController ?? navigationController
    //    presentingController.present(navigationControllerOpticalVTO, animated: true)
    //    navigationControllerOpticalVTO.navigationBar.isHidden = true
    //    viewController.navigationPresentedController = navigationControllerOpticalVTO
    //    navigationControllerOpticalVTO.pushViewController(viewController, animated: true)
    // }
    func willRouteWith(_ vc: UIViewController) {
        navigationController.pushViewController(vc, animated: true)
    }

    func willRouteTab(_ vc: UITabBarController) {
        navigationController.pushViewController(vc, animated: true)
    }
}
