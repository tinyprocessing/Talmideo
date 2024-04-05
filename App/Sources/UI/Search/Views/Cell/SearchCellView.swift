import Foundation
import UIKit

class SearchCellView: UIView {
    let leftLabel = UILabel()
    let rightLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 15
        clipsToBounds = true

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.numberOfLines = 1
        leftLabel.lineBreakMode = .byTruncatingTail

        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.numberOfLines = 1
        rightLabel.lineBreakMode = .byTruncatingTail

        addSubview(leftLabel)
        addSubview(rightLabel)

        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.padding),
            leftLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: rightLabel.leadingAnchor,
                constant: -Config.gapBetweenLabels
            ),

            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Config.padding),
            rightLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leftLabel.trailingAnchor,
                constant: Config.gapBetweenLabels
            ),

            heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private enum Config {
        static let padding: CGFloat = 16
        static let gapBetweenLabels: CGFloat = 8
    }
}
