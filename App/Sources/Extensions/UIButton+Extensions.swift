import Foundation
import UIKit

class ActionButton: UIButton {
    convenience init() {
        self.init(frame: .zero)
        setupButton()
    }

    private func setupButton() {
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: .touchUpInside)
        addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        addTarget(self, action: #selector(buttonReleased), for: .touchCancel)
    }

    @objc func buttonPressed() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: [.allowUserInteraction, .curveEaseOut],
                       animations: {
                           self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                       }, completion: nil)
    }

    @objc func buttonReleased() {
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6.0,
                       options: [.allowUserInteraction, .curveEaseIn],
                       animations: {
                           self.transform = .identity
                       }, completion: nil)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
