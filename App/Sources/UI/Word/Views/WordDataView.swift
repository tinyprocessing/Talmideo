import Foundation
import UIKit

class WordDataView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.contentHuggingPriority(for: .vertical)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public enum State {
        case present(value: Present)
        case passivePresent(value: Present)
        case past(value: [String: InitialForm])
        case future(value: [String: InitialForm])
        case imperative(value: [String: InitialForm])
        case passiveFuture(value: [String: InitialForm])
        case passivePast(value: [String: InitialForm])
    }

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
        addSubview(stackView)
        configure()
    }

    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 20

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }

    public func update(_ status: State) {
        switch status {
        case .present(let value):
            titleLabel.text = Config.present
            present(value)
        case .passivePresent(let value):
            titleLabel.text = Config.passivePresent
            present(value)
        case .past(let value):
            titleLabel.text = Config.past
            tenses(value)
        case .future(let value):
            titleLabel.text = Config.future
            tenses(value)
        case .imperative(let value):
            titleLabel.text = Config.imperative
            tenses(value)
        case .passiveFuture(let value):
            titleLabel.text = Config.passiveFuture
            tenses(value)
        case .passivePast(let value):
            titleLabel.text = Config.passivePast
            tenses(value)
        }
    }

    fileprivate func present(_ value: Present) {
        let forms = [
            (value.mp, value.ms, "אנחנו\nאתם\nהם", "אני\nאתה\nהוא"),
            (value.fp, value.fs, "אנחנו\nאתן\nהן", "אני\nאת\nהיא")
        ]

        for (leftValue, rightValue, leftForms, rightForms) in forms {
            guard let leftValue = leftValue, let rightValue = rightValue else {
                continue
            }

            let rowView = WordDataRowView(left: .init(value: leftValue.value ?? "",
                                                      forms: leftForms,
                                                      transliteration: leftValue.transcriptionEn ?? ""),
                                          right: .init(value: rightValue.value ?? "",
                                                       forms: rightForms,
                                                       transliteration: rightValue.transcriptionEn ?? ""))
            stackView.addArrangedSubview(rowView)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    fileprivate func tenses(_ value: [String: InitialForm]) {
        let forms = [("1p", Config.oneP, "1s", Config.oneS),
                     ("2mp", Config.twoMP, "2ms", Config.twoMS),
                     ("2fp", Config.twoFP, "2fs", Config.twoFS),
                     ("3p", Config.treeSP, "3ms", Config.treeMS),
                     ("3p", Config.treeMP, "3fs", Config.treeFS)]

        for (leftKey, leftForms, rightKey, rightForms) in forms {
            let leftValue = value[leftKey]?.value ?? ""
            let leftTransliteration = value[leftKey]?.transcriptionEn ?? ""
            let rightValue = value[rightKey]?.value ?? ""
            let rightTransliteration = value[rightKey]?.transcriptionEn ?? ""

            let rowView = WordDataRowView(
                left: .init(value: leftValue, forms: leftForms, transliteration: leftTransliteration),
                right: .init(value: rightValue, forms: rightForms, transliteration: rightTransliteration)
            )
            stackView.addArrangedSubview(rowView)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 400)
        ])
    }

    private enum Config {
        static let title = ""
        static let present = "Present"
        static let passivePresent = "Passive Present"
        static let past = "Past"
        static let future = "Future"
        static let imperative = "Imperative"
        static let passiveFuture = "Passive Future"
        static let passivePast = "Passive Past"

        static let oneP = "אנחנו"
        static let oneS = "אני"
        static let twoMP = "אתם"
        static let twoMS = "אתה"
        static let twoFP = "אתן"
        static let twoFS = "את"
        static let treeMP = "הם"
        static let treeSP = "הן"
        static let treeFS = "היא"
        static let treeMS = "הוא"
    }
}
