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
        label.font = UIFont.customFont(.robotoSlabMedium, size: 18)
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
        case pronoun(value: [String: InitialForm])
        case past(value: [String: InitialForm])
        case future(value: [String: InitialForm])
        case imperative(value: [String: InitialForm])
        case passiveFuture(value: [String: InitialForm])
        case passivePast(value: [String: InitialForm])
        case noun(value: Main, gender: String)
        case adjective(value: Main)
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
            tenses(value, true)
        case .imperative(let value):
            titleLabel.text = Config.imperative
            tenses(value)
        case .passiveFuture(let value):
            titleLabel.text = Config.passiveFuture
            tenses(value)
        case .passivePast(let value):
            titleLabel.text = Config.passivePast
            tenses(value)
        case .noun(let value, let gender):
            titleLabel.text = Config.noun
            noun(value, gender)
        case .adjective(let value):
            titleLabel.text = Config.adjective
            adjective(value)
        case .pronoun(let value):
            titleLabel.text = Config.pronoun
            tenses(value, true)
        }
    }

    fileprivate func adjective(_ value: Main) {
        let forms = [(value.mp, "אנחנו\nאתם\nהם", value.ms, "אני\nאתה\nהוא"),
                     (value.fp, "אנחנו\nאתן\nהן", value.fs, "אני\nאת\nהיא")]

        for (leftValue, leftForms, rightValue, rightForms) in forms {
            let rowView = WordDataRowView(left: .init(value: leftValue?.value ?? "",
                                                      forms: leftForms,
                                                      transliteration: leftValue?.transcription ?? "-"),
                                          right: .init(value: rightValue?.value ?? "",
                                                       forms: rightForms,
                                                       transliteration: rightValue?.transcription ?? "-"))
            stackView.addArrangedSubview(rowView)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    fileprivate func noun(_ value: Main, _ gender: String) {
        var forms = [
            (value.p, value.s, Config.treeMP, Config.treeMS)
        ]
        if gender == "F" {
            forms = [
                (value.p, value.s, Config.treeSP, Config.treeFS)
            ]
        }
        for (leftValue, rightValue, leftForms, rightForms) in forms {
            let rowView = WordDataRowView(left: .init(value: leftValue?.value ?? "-",
                                                      forms: leftForms,
                                                      transliteration: leftValue?.transcription ?? "-"),
                                          right: .init(value: rightValue?.value ?? "-",
                                                       forms: rightForms,
                                                       transliteration: rightValue?.transcription ?? "-"))
            stackView.addArrangedSubview(rowView)
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 135)
            ])
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
                                                      transliteration: leftValue.transcription),
                                          right: .init(value: rightValue.value ?? "",
                                                       forms: rightForms,
                                                       transliteration: rightValue.transcription))
            stackView.addArrangedSubview(rowView)
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    fileprivate func tenses(_ value: [String: InitialForm], _ isFuture: Bool = false) {
        var forms = [("1p", Config.oneP, "1s", Config.oneS),
                     ("2mp", Config.twoMP, "2ms", Config.twoMS),
                     ("2fp", Config.twoFP, "2fs", Config.twoFS),
                     ("3p", Config.treeSP, "3ms", Config.treeMS),
                     ("3p", Config.treeMP, "3fs", Config.treeFS)]

        if isFuture {
            forms = [
                ("1p", Config.oneP, "1s", Config.oneS),
                ("2mp", Config.twoMP, "2ms", Config.twoMS),
                ("2fp", Config.twoFP, "2fs", Config.twoFS),
                ("3fp", Config.treeSP, "3ms", Config.treeMS),
                ("3mp", Config.treeMP, "3fs", Config.treeFS)
            ]
        }

        for (leftKey, leftForms, rightKey, rightForms) in forms {
            let leftValue = value[leftKey]?.value ?? ""
            let leftTransliteration = value[leftKey]?.transcription ?? ""
            let rightValue = value[rightKey]?.value ?? ""
            let rightTransliteration = value[rightKey]?.transcription ?? ""

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
        static let present: String = .localized(.present)
        static let passivePresent: String = .localized(.passivePresent)
        static let past: String = .localized(.past)
        static let future: String = .localized(.future)
        static let imperative: String = .localized(.imperative)
        static let passiveFuture: String = .localized(.passiveFuture)
        static let passivePast: String = .localized(.passivePast)
        static let noun: String = .localized(.noun)
        static let adjective: String = .localized(.adjective)
        static let pronoun: String = .localized(.pronoun)

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
