import Foundation
import UIKit

class TabViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func setupTabBarItems(with viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers.map { viewController -> UIViewController in
            viewController
        }

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = Config.colorSelected
        tabBar.unselectedItemTintColor = Config.color
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
    }

    private enum Config {
        static let colorSelected: UIColor = .black
        static let color = UIColor(hex: "C4C4C4")
    }
}
