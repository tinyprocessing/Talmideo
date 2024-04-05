import UIKit

extension UIView {
    func fadeIn(
        _ duration: TimeInterval = Constants.DefaultAnimationDuration,
        onCompletion: (() -> Void)? = nil
    ) {
        alpha = 0
        isHidden = false
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = 1 },
            completion: { (_: Bool) in
                if let complete = onCompletion { complete() }
            }
        )
    }

    func fadeOut(
        _ duration: TimeInterval = Constants.DefaultAnimationDuration,
        onCompletion: (() -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            animations: { self.alpha = .zero },
            completion: { (_: Bool) in
                self.isHidden = true
                if let complete = onCompletion { complete() }
            }
        )
    }

    func addAutoLayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    func addAutoLayoutSubviews(_ subviews: [UIView]) {
        subviews.forEach { addAutoLayoutSubview($0) }
    }
}
