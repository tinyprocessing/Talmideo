import Combine
import Foundation
import UIKit

class SettingsCellView: UIView {
    private let model: SettingsCoordinator.SettingsCellModel
    private var context: CurrentValueSubject<TalmideoContext, Never>
    private var cancellables = Set<AnyCancellable>()

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
        label.font = UIFont.customFont(.robotoSlabRegular, size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var actionButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(model.actionButtonTitle, for: .normal)
        button.backgroundColor = .secondaryLabel.withAlphaComponent(0.05)
        button.layer.cornerRadius = 12.5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.customFont(.robotoSlabRegular, size: 14)
        button.setTitleColor(.black.withAlphaComponent(0.7), for: .normal)
        button.tintColor = .black
        button.isHidden = true
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        if model.isActionDanger {
            button.setTitleColor(.red.withAlphaComponent(0.7), for: .normal)
            button.tintColor = .red
        }
        if model.actionButtonTitle.isEmpty {
            button.isHidden = true
        }
        let padding: CGFloat = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        return button
    }()

    private lazy var switchAction: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(swipeActionTapped), for: .valueChanged)
        view.isOn = model.swipeDefaultValue
        view.isHidden = true
        return view
    }()

    init(_ model: SettingsCoordinator.SettingsCellModel, context: CurrentValueSubject<TalmideoContext, Never>) {
        self.model = model
        self.context = context
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
        wrapperView.addSubview(switchAction)

        context
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if model.type == .bookmarks, context.value.state == .bookmarks {
                    let bookmars = BookmarkManager()
                    actionButton.setTitle("\(bookmars.count)", for: .normal)
                }
                if model.type == .swipeNotifications, context.value.state == .notifications {
                    switchAction.isOn = CacheManager.shared.getNotifications()
                }
            }
            .store(in: &cancellables)
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            wrapperView.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),

            titleLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -10)
        ])

        if model.type == .general || model.type == .bookmarks {
            actionButton.isHidden = false
            NSLayoutConstraint.activate([
                actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                actionButton.heightAnchor.constraint(equalToConstant: 25),
                actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
            ])
        }
        if model.type == .swipeNotifications || model.type == .swipeSpeech || model.type == .swipeSounds{
            switchAction.isHidden = false
            NSLayoutConstraint.activate([
                switchAction.centerYAnchor.constraint(equalTo: centerYAnchor),
                switchAction.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
            ])
        }
        backgroundColor = .clear
    }

    @objc private func actionButtonTapped() {
        model.action?()
    }

    @objc private func swipeActionTapped() {
        if switchAction.isOn {
            model.swipeActionTrue?()
        } else {
            model.swipeActionFalse?()
        }
    }
}
