import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let router = Router(baseRoute: Constants.InitialRouteType)
    private var coordinator: TalmideoCoordinator? = nil

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = router.navigationController
        window?.makeKeyAndVisible()

        coordinator = TalmideoCoordinator(router: router)
        if let coordinator = coordinator {
            coordinator.start()
            coordinator.onFinish = { result in
                print("Task finished with result: \(result)")
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
