import Combine
import UIKit

class SettingsViewController: BaseViewController {
    private let model: SettingsCoordinator.SettingsModel
    private var context: CurrentValueSubject<TalmideoContext, Never>

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
        view.spacing = 5
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(_ model: SettingsCoordinator.SettingsModel, context: CurrentValueSubject<TalmideoContext, Never>) {
        self.model = model
        self.context = context
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

    private func generateSettingsCellView(_ model: SettingsCoordinator.SettingsCellModel) {
        let view = SettingsCellView(model, context: context)
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(view)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 70),
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 15),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -15),
            view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor)
        ])
    }

    private func generateSettingsSectionView(_ model: SettingsCoordinator.SettingsSectionModel) {
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

        model.settingsSections.forEach { settingsModel in
            generateSettingsSectionView(settingsModel)
            settingsModel.options.forEach { model in
                generateSettingsCellView(model)
            }
        }
    }

    private enum Config {
        static let title: String = .localized(.settings)
        static let settingsViewCell = "SettingsViewCell"
    }
}
