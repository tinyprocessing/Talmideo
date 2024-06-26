import UIKit

extension BaseViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(BaseViewController.dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        view.endEditing(true)
    }
}

extension UIView {
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat = 0,
                height: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false

        var anchors = [NSLayoutConstraint]()

        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
        }
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
        }
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
        }
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
        }
        if width > 0 {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        if height > 0 {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }

        anchors.forEach { $0.isActive = true }

        return anchors
    }

    @discardableResult
    func anchorToSuperview() -> [NSLayoutConstraint] {
        return anchor(top: superview?.topAnchor,
                      left: superview?.leftAnchor,
                      bottom: superview?.bottomAnchor,
                      right: superview?.rightAnchor)
    }
}

extension UIView {
    func applyShadow(radius: CGFloat,
                     opacity: Float,
                     offset: CGSize,
                     color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}

extension UIViewController {
    func resetToInitialState() {
        for childVC in children {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }

        view.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIPageViewController {
    func createNextPageViewController() -> UIViewController? {
        guard let currentViewController = viewControllers?.first else { return nil }
        return dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
    }

    func createPreviousPageViewController() -> UIViewController? {
        guard let currentViewController = viewControllers?.first else { return nil }
        return dataSource?.pageViewController(self, viewControllerBefore: currentViewController)
    }

    func goToNextPage(animated: Bool = true) {
        guard let nextPageViewController = createNextPageViewController(),
              let current = viewControllers?.first
        else { return }
        setViewControllers([nextPageViewController], direction: .forward, animated: animated, completion: nil)
        delegate?.pageViewController?(
            self,
            didFinishAnimating: true,
            previousViewControllers: [current],
            transitionCompleted: true
        )
    }

    func goToPreviousPage(animated: Bool = true) {
        guard let previousPageViewController = createPreviousPageViewController() else { return }
        setViewControllers([previousPageViewController], direction: .reverse, animated: animated, completion: nil)
    }
}
