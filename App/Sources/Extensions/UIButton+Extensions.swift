import UIKit

class ActionButton: UIButton {
    convenience init() {
        self.init(frame: .zero)
        setupButton()
    }

    private func setupButton() {
        addTarget(self, action: #selector(scaleButton(_:)), for: .touchDown)
        addTarget(self, action: #selector(scaleButton(_:)), for: .touchUpOutside)
        addTarget(self, action: #selector(scaleButton(_:)), for: .touchUpInside)
    }

    @objc private func scaleButton(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2,
                       animations: {
                           self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.2) {
                               self.transform = .identity
                           }
                       })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
