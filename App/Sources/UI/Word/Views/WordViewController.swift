import Combine
import UIKit

class WordViewController: BaseViewController {
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
        view.backgroundColor = Config.backgroundColor

        let backButton = UIButton(type: .system)
        backButton.setImage(Config.iconBack, for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = Config.buttonColor
        backButton.layer.cornerRadius = 15
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private enum Config {
        static let backgroundColor = UIColor(hex: "F5F8FA")
        static let buttonColor = UIColor(hex: "FFC75A")
        static var iconBack: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
            return UIImage(systemName: "chevron.left", withConfiguration: config) ?? UIImage()
        }
    }
}
