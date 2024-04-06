import Combine
import UIKit

class WordViewController: BaseViewController {
    private var model: CurrentValueSubject<WordModel, Never>
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Config.iconBack, for: .normal)
        button.tintColor = .white
        button.backgroundColor = Config.buttonColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var wordHeaderView: WordHeaderView = {
        let view = WordHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(model: CurrentValueSubject<WordModel, Never>) {
        self.model = model
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

        model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.update()
            }
            .store(in: &cancellables)

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        setupScrollView()
        setupStackView()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: 0)
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(wordHeaderView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            wordHeaderView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            wordHeaderView.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -30)
        ])
    }

    // MARK: Actions

    private func update() {
        wordHeaderView.update(model.value)

        stackView.arrangedSubviews.forEach { view in
            if let view = view as? WordDataView {
                view.removeFromSuperview()
            }
        }

        if model.value.partOfSpeech == "V" {
            if let present = model.value.forms?.present {
                let view = createWordDataView()
                view.update(.present(value: present))
            }
            if let passivePresent = model.value.forms?.passivePresent {
                let view = createWordDataView()
                view.update(.passivePresent(value: passivePresent))
            }
            if let past = model.value.forms?.past {
                let view = createWordDataView()
                view.update(.past(value: past))
            }
            if let future = model.value.forms?.future {
                let view = createWordDataView()
                view.update(.future(value: future))
            }
        }
    }

    private func createWordDataView() -> WordDataView {
        let view = WordDataView()
        stackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -30).isActive = true
        view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        return view
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
