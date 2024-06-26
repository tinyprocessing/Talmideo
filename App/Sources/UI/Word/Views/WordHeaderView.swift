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
        label.font = UIFont.customFont(.robotoSlabMedium, size: 22)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabRegular, size: 14)
        return label
    }()

    private lazy var meaningLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabRegular, size: 16)
        return label
    }()

    private lazy var rootLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabRegular, size: 16)
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
            titleLabel.widthAnchor.constraint(equalToConstant: 100),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 20),
            meaningLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            meaningLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            meaningLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 5),
            meaningLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            meaningLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            rootLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            rootLabel.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 20),
            rootLabel.heightAnchor.constraint(equalToConstant: 20),
            rootLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            heightAnchor.constraint(equalToConstant: 135)
        ])
    }

    public func update(_ model: WordModel) {
        rootLabel.text = ""
        if let form = model.initialForm {
            titleLabel.text = form.value
            if let light = (form.transcription).highlightCharacterAfterSymbol(symbol: "`") {
                subtitleLabel.attributedText = light
            } else {
                subtitleLabel.text = form.transcription
            }
        }
        if let meaning = model.meaning {
            if let gender = model.gender {
                let genderDescription: String
                switch gender {
                case "M":
                    genderDescription = Config.masculine
                case "F":
                    genderDescription = Config.feminine
                default:
                    genderDescription = ""
                }
                meaningLabel.text = "\(meaning.locale) (\(genderDescription))"
            } else {
                meaningLabel.text = meaning.locale
            }
        }
        if let root = model.root {
            rootLabel.text = concatenateStrings(root)
        }
    }

    private func concatenateStrings(_ strings: [String]) -> String {
        return strings.joined(separator: "-")
    }

    private enum Config {
        static let title = ""
        static let masculine: String = .localized(.masculine)
        static let feminine: String = .localized(.feminine)
    }
}
