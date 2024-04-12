import Foundation
import UIKit

class SettingsCellView: UIView {
    private let model: SettingsViewController.SettingsCellModel

    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = model.title
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.setTitle(model.actionButtonTitle, for: .normal)
        button.backgroundColor = .secondaryLabel.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.black.withAlphaComponent(0.7), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        if model.actionButtonTitle.isEmpty {
            button.isHidden = true
        }
        return button
    }()

    init(_ model: SettingsViewController.SettingsCellModel) {
        self.model = model
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(wrapperView)
        wrapperView.addSubview(titleLabel)
        wrapperView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),

            titleLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -10),

            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 25),
            actionButton.widthAnchor.constraint(equalToConstant: 70),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])

        backgroundColor = .clear
    }

    @objc private func actionButtonTapped() {
        model.action?()
    }
}
