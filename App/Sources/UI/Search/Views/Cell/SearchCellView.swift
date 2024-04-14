import Foundation
import UIKit

class SearchCellView: UIView, UIGestureRecognizerDelegate {
    var id = 0
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    var callback: ((_ id: Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        callback?(id)
    }

    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 15
        clipsToBounds = true

        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.numberOfLines = 1
        leftLabel.lineBreakMode = .byTruncatingTail
        leftLabel.isUserInteractionEnabled = true
        leftLabel.font = UIFont.customFont(.robotoSlabRegular, size: 16)

        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.numberOfLines = 1
        rightLabel.lineBreakMode = .byTruncatingTail
        rightLabel.textAlignment = .right
        rightLabel.isUserInteractionEnabled = true
        rightLabel.font = UIFont.customFont(.robotoSlabRegular, size: 16)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        rightLabel.addGestureRecognizer(tapRecognizer)
        leftLabel.addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(tapRecognizer)

        addSubview(leftLabel)
        addSubview(rightLabel)

        NSLayoutConstraint.activate([
            rightLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Config.padding),
            rightLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightLabel.widthAnchor.constraint(equalToConstant: 100),
            rightLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: leftLabel.trailingAnchor,
                constant: Config.gapBetweenLabels
            ),

            leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Config.padding),
            leftLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            leftLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: rightLabel.leadingAnchor,
                constant: -Config.gapBetweenLabels
            ),
            heightAnchor.constraint(equalToConstant: 50)
        ])

        for subview in subviews {
            if let gestureRecognizers = subview.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    recognizer.delegate = self
                }
            }
        }
    }

    private enum Config {
        static let padding: CGFloat = 16
        static let gapBetweenLabels: CGFloat = 8
    }
}
