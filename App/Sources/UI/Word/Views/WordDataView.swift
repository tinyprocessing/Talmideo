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
            let rowFirst = WordDataRowView(left: .init(value: value.mp?.value ?? "",
                                                       forms: "אנחנו\nאתם\nהם",
                                                       transliteration: value.mp?.transcriptionEn ?? ""),
                                           right: .init(value: value.ms?.value ?? "",
                                                        forms: "אני\nאתה\nהוא",
                                                        transliteration: value.ms?.transcriptionEn ?? ""))
            let rowSecond = WordDataRowView(left: .init(value: value.fp?.value ?? "",
                                                        forms: "אנחנו\nאתן\nהן",
                                                        transliteration: value.fp?.transcriptionEn ?? ""),
                                            right: .init(value: value.fs?.value ?? "",
                                                         forms: "אני\nאת\nהיא",
                                                         transliteration: value.fs?.transcriptionEn ?? ""))
            stackView.addArrangedSubview(rowFirst)
            stackView.addArrangedSubview(rowSecond)
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 220)
            ])
        case .passivePresent(let value):
            titleLabel.text = Config.passivePresent
            let rowFirst = WordDataRowView(left: .init(value: value.mp?.value ?? "",
                                                       forms: "אנחנו\nאתם\nהם",
                                                       transliteration: value.mp?.transcriptionEn ?? ""),
                                           right: .init(value: value.ms?.value ?? "",
                                                        forms: "אני\nאתה\nהוא",
                                                        transliteration: value.ms?.transcriptionEn ?? ""))
            let rowSecond = WordDataRowView(left: .init(value: value.fp?.value ?? "",
                                                        forms: "אנחנו\nאתן\nהן",
                                                        transliteration: value.fp?.transcriptionEn ?? ""),
                                            right: .init(value: value.fs?.value ?? "",
                                                         forms: "אני\nאת\nהיא",
                                                         transliteration: value.fs?.transcriptionEn ?? ""))
            stackView.addArrangedSubview(rowFirst)
            stackView.addArrangedSubview(rowSecond)
            NSLayoutConstraint.activate([
                heightAnchor.constraint(equalToConstant: 220)
            ])
        }
    }

    private enum Config {
        static let title = ""
        static let present = "Present"
        static let passivePresent = "Passive Present"
    }
}
