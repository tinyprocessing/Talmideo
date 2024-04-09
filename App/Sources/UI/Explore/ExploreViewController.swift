import Combine
import UIKit

protocol ExploreViewControllerDelegate: AnyObject {
    func didTap(model: ExploreItemView.ExploreItemModel)
}

class ExploreViewController: BaseViewController {
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    public var exploreDelegate: ExploreViewControllerDelegate?

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

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        setupScrollView()
        setupStackView()
        setupExploreItem(.init(
            type: .noun,
            image: "ExploreNoun",
            title: "Nouns",
            subtitle: "4,370",
            secondary: "Start learning"
        ))
        setupExploreItem(.init(
            type: .verb,
            image: "ExploreVerb",
            title: "Verbs",
            subtitle: "3,440",
            secondary: "Start learning"
        ))
        setupExploreItem(.init(
            type: .adjective,
            image: "ExploreAdjective",
            title: "Adjectives",
            subtitle: "948",
            secondary: "Start learning"
        ))
    }

    private func setupExploreItem(_ model: ExploreItemView.ExploreItemModel) {
        let view = ExploreItemView(model: model)
        view.delegate = self
        stackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -30).isActive = true
        view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
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

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private enum Config {
        static let title = "Explore"
    }
}

extension ExploreViewController: ExploreItemViewDelegate {
    func didTap(_ model: ExploreItemView.ExploreItemModel) {
        exploreDelegate?.didTap(model: model)
    }
}
