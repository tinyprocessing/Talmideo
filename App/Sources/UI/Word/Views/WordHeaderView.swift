import Foundation
import UIKit

class WordHeaderView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()

    private lazy var meaningLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private lazy var rootLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(meaningLabel)
        addSubview(rootLabel)
        configure()
    }

    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 20),
            meaningLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            meaningLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            meaningLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            rootLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            rootLabel.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 20),
            rootLabel.heightAnchor.constraint(equalToConstant: 20),
            rootLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            heightAnchor.constraint(equalToConstant: 135)
        ])
    }

    public func update(_ model: WordModel) {
        if let form = model.initialForm {
            titleLabel.text = form.value
            if let light = highlightCharacterAfterSymbol(form.transcriptionRu ?? "", symbol: "`") {
                subtitleLabel.attributedText = light
            } else {
                subtitleLabel.text = form.transcriptionRu
            }
        }
        if let meaning = model.meaning {
            if let gender = model.gender {
                let genderDescription: String
                switch gender {
                case "M":
                    genderDescription = "мужской род"
                case "F":
                    genderDescription = "женский род"
                default:
                    genderDescription = ""
                }
                meaningLabel.text = "\(meaning.ru ?? "") (\(genderDescription))"
            } else {
                meaningLabel.text = meaning.ru
            }
        }
        if let root = model.root {
            rootLabel.text = concatenateStrings(root)
        }
        print(model)
        setNeedsLayout()
    }

    private func highlightCharacterAfterSymbol(_ inputString: String, symbol: Character) -> NSAttributedString? {
        guard inputString.range(of: String(symbol)) != nil else {
            return nil
        }

        if let firstIndex = inputString.firstIndex(of: symbol) {
            let char = inputString.index(after: firstIndex)
            guard inputString.indices.contains(char) else {
                return nil
            }
            let attributedString = NSMutableAttributedString(string: inputString)

            let redAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red]
            attributedString.addAttributes(
                redAttributes,
                range: NSRange(location: inputString.distance(from: inputString.startIndex, to: char), length: 1)
            )

            let index: Int = inputString.distance(from: inputString.startIndex, to: firstIndex)
            attributedString.deleteCharacters(in: NSRange(location: index, length: 1))

            return attributedString
        }

        return nil
    }

    private func concatenateStrings(_ strings: [String]) -> String {
        return strings.joined(separator: "-")
    }

    private enum Config {
        static let title = ""
    }
}
