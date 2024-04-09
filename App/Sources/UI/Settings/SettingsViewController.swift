import UIKit

struct SettingsSection {
    let title: String
    let options: [String]
}

class SettingsViewController: BaseViewController {
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

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsViewCell.self, forCellReuseIdentifier: "SettingsViewCell")
        tableView.backgroundColor = Constants.backgroundColor
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.contentInset = UIEdgeInsets.zero
        return tableView
    }()

    private let settingsSections: [SettingsSection] = [
        SettingsSection(
            title: "General Settings",
            options: ["Notifications", "Bookmarks"]
        ),
        SettingsSection(
            title: "Advanced Settings",
            options: ["Clear history"]
        ),
        SettingsSection(
            title: "Contact",
            options: ["Github", "Website", "Mail"]
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

    private func configure() {
        view.backgroundColor = Constants.backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private enum Config {
        static let title = "Settings"
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsSections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingsViewCell",
            for: indexPath
        ) as! SettingsViewCell
        cell.titleLabel.text = settingsSections[indexPath.section].options[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = Constants.backgroundColor

        let titleLabel = UILabel()
        titleLabel.text = settingsSections[section].title
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsSections[section].title
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

class SettingsViewCell: UITableViewCell {
    let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        addSubview(wrapperView)
        wrapperView.addSubview(titleLabel)

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

        backgroundColor = .clear
    }
}
