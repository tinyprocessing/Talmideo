import UIKit

extension UIStackView {
    convenience init(
        axis: NSLayoutConstraint.Axis,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        spacing: CGFloat = 0
    ) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview(_:))
    }

    func addArrangedSubviews(_ views: UIView...) {
        addArrangedSubviews(views)
    }

    func addArrangedSubview(_ arrangedSubview: UIView, customSpacing spacing: CGFloat) {
        addArrangedSubview(arrangedSubview)
        setCustomSpacing(spacing, after: arrangedSubview)
    }
}
