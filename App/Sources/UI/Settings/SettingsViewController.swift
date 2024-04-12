import UIKit

class TouchPassingTableView: UITableView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        print("need to cancel touch")
        return false
    }

    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        return true
    }
}

class SettingsViewController: BaseViewController {
    struct SettingsSectionModel {
        let title: String
        let options: [SettingsCellModel]
    }

    struct SettingsCellModel {
        let title: String
        let actionButtonTitle: String
        let action: (() -> Void)?

        init(title: String, actionButtonTitle: String, action: (() -> Void)?) {
            self.title = title
            self.actionButtonTitle = actionButtonTitle
            self.action = action
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(axis: .vertical)
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let settingsSections: [SettingsSectionModel] = [
        SettingsSectionModel(
            title: "General Settings",
            options: [.init(title: "Notifications", actionButtonTitle: "", action: nil),
                      .init(title: "Bookmarks", actionButtonTitle: "", action: nil)]
        ),
        SettingsSectionModel(
            title: "Advanced Settings",
            options: [.init(title: "Clear history", actionButtonTitle: "Delete", action: nil)]
        ),
        SettingsSectionModel(
            title: "Contact",
            options: [.init(title: "Github", actionButtonTitle: "Open", action: {
                print("open github")
            }),
            .init(title: "Website", actionButtonTitle: "Open", action: {}),
            .init(title: "Mail", actionButtonTitle: "Send", action: {})]
        )
    ]

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func generateSettingsCellView(_ model: SettingsCellModel) {
        let view = SettingsCellView(model)
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 70),
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 15),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -15),
            view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ])
    }

    private func generateSettingsSectionView(_ model: SettingsSectionModel) {
        let label = UILabel()
        label.text = model.title
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -15),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func configure() {
        view.backgroundColor = Constants.backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        settingsSections.forEach { settingsModel in
            generateSettingsSectionView(settingsModel)
            settingsModel.options.forEach { model in
                generateSettingsCellView(model)
            }
        }
    }

    private enum Config {
        static let title = "Settings"
        static let settingsViewCell = "SettingsViewCell"
    }
}
