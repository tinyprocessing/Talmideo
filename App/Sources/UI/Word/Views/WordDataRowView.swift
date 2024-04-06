import Foundation
import UIKit

class WordDataRowView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var leftValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var leftTransliterationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var rightValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var rightTransliterationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public struct Item {
        var value: String
        var forms: String
        var transliteration: String
    }

    init(left: Item, right: Item) {
        super.init(frame: .zero)
        setupViews()
        leftLabel.text = left.forms
        leftValueLabel.text = left.value
        if let text = left.transliteration.highlightCharacterAfterSymbol(symbol: "`") {
            leftTransliterationLabel.attributedText = text
        } else {
            leftTransliterationLabel.text = left.transliteration
        }

        rightLabel.text = right.forms
        rightValueLabel.text = right.value
        if let text = right.transliteration.highlightCharacterAfterSymbol(symbol: "`") {
            rightTransliterationLabel.attributedText = text
        } else {
            rightTransliterationLabel.text = right.transliteration
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let leftBlockStackView = UIStackView()
        leftBlockStackView.axis = .vertical
        leftBlockStackView.translatesAutoresizingMaskIntoConstraints = false
        leftBlockStackView.spacing = 4
        leftBlockStackView.addArrangedSubview(leftValueLabel)
        leftBlockStackView.addArrangedSubview(leftTransliterationLabel)

        leftLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let leftStackView = UIStackView()
        leftStackView.axis = .horizontal
        leftStackView.alignment = .top
        leftStackView.distribution = .fillProportionally
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.spacing = 4
        leftStackView.addArrangedSubview(leftBlockStackView)
        leftStackView.addArrangedSubview(leftLabel)

        let rightBlockStackView = UIStackView()
        rightBlockStackView.axis = .vertical
        rightBlockStackView.translatesAutoresizingMaskIntoConstraints = false
        rightBlockStackView.spacing = 4
        rightBlockStackView.addArrangedSubview(rightValueLabel)
        rightBlockStackView.addArrangedSubview(rightTransliterationLabel)

        rightLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let rightStackView = UIStackView()
        rightStackView.axis = .horizontal
        rightStackView.alignment = .top
        rightStackView.spacing = 4
        rightStackView.distribution = .fillProportionally
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.addArrangedSubview(rightBlockStackView)
        rightStackView.addArrangedSubview(rightLabel)

        stackView.addArrangedSubview(leftStackView)
        stackView.addArrangedSubview(rightStackView)
    }
}
