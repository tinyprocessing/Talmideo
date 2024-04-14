import Combine
import UIKit

protocol ExploreViewControllerDelegate: AnyObject {
    func didTap(model: ExploreItemView.ExploreItemModel)
}

class ExploreViewController: BaseViewController {
    private var cancellables = Set<AnyCancellable>()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let bookmarks = BookmarkManager()
    private let context: CurrentValueSubject<TalmideoContext, Never>

    public var exploreDelegate: ExploreViewControllerDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Config.title
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.customFont(.robotoSlabMedium, size: 28)
        return label
    }()

    private var bookmarksView: ExploreItemView? = nil

    init(context: CurrentValueSubject<TalmideoContext, Never>) {
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

    public func updateBookmarks() {
        if bookmarksView == nil && bookmarks.count > 3 {
            setupExploreItem(.init(
                type: .bookmarks,
                image: "background4",
                title: .localized(.bookmarks),
                subtitle: "\(bookmarks.count)",
                secondary: .localized(.repeat)
            ))
        } else if bookmarksView != nil && bookmarks.count <= 3 {
            bookmarksView?.removeFromSuperview()
            stackView.arrangedSubviews.forEach { view in
                if view == bookmarksView {
                    view.removeFromSuperview()
                }
            }
            bookmarksView = nil
        }
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
            image: "background1",
            title: .localized(.nouns),
            subtitle: "4,370",
            secondary: .localized(.startLearning)
        ))
        setupExploreItem(.init(
            type: .verb,
            image: "background2",
            title: .localized(.verbs),
            subtitle: "3,440",
            secondary: .localized(.startLearning)
        ))
        setupExploreItem(.init(
            type: .adjective,
            image: "background3",
            title: .localized(.adjectives),
            subtitle: "948",
            secondary: .localized(.startLearning)
        ))
    }

    private func setupExploreItem(_ model: ExploreItemView.ExploreItemModel) {
        let view = ExploreItemView(model: model, context: context)
        view.delegate = self
        if model.type == .bookmarks {
            bookmarksView = view
            stackView.insertArrangedSubview(view, at: 0)
        } else {
            stackView.addArrangedSubview(view)
        }
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
        static let title: String = .localized(.explore)
    }
}

extension ExploreViewController: ExploreItemViewDelegate {
    func didTap(_ model: ExploreItemView.ExploreItemModel) {
        exploreDelegate?.didTap(model: model)
    }
}
