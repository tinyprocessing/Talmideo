import Combine
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchBar(textDidChange searchText: String)
    func didSelectItem(id: Int)
    func close()
}

class SearchViewController: BaseViewController {
    var searchDelegate: SearchViewControllerDelegate?

    private var model: CurrentValueSubject<SearchViewModel, Never>
    private var cancellables = Set<AnyCancellable>()
    public let bookmarks: BookmarkManager?

    private lazy var safeAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "B4DDD3")
        return view
    }()

    private lazy var searchHeader: SearchHeaderView = {
        let view = SearchHeaderView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var searchList: SearchListView = {
        let view = SearchListView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(
        searchDelegate: SearchViewControllerDelegate? = nil,
        model: CurrentValueSubject<SearchViewModel, Never>,
        bookmarks: BookmarkManager
    ) {
        self.searchDelegate = searchDelegate
        self.model = model
        self.bookmarks = bookmarks
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
        hideKeyboardWhenTappedAround()

        view.backgroundColor = Config.backgroundColor
        view.addSubview(searchHeader)
        view.addSubview(searchList)
        view.addSubview(safeAreaView)

        model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.update()
            }
            .store(in: &cancellables)

        NSLayoutConstraint.activate([
            searchHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchHeader.heightAnchor.constraint(equalToConstant: Config.searchHeaderHeight),

            safeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            safeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            searchList.topAnchor.constraint(equalTo: searchHeader.bottomAnchor, constant: Config.searchListPaddingTop),
            searchList.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            searchList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Config.searchListPadding),
            searchList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Config.searchListPadding)
        ])
    }

    // MARK: Actions

    private func update() {
        var array: [(Int, String, String, Bool)] = []
        model.value.result.forEach { word in
            array.append((word.id, word.meaning, word.form, false))
        }
        searchList.refreshWithData(array)
    }

    private enum Config {
        static let backgroundColor = UIColor(hex: "F5F8FA")
        static let searchHeaderHeight: CGFloat = 120
        static let searchListPadding: CGFloat = 10
        static let searchListPaddingTop: CGFloat = 20
    }
}

extension SearchViewController: SearchHeaderDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDelegate?.searchBar(textDidChange: searchText)
    }
}

extension SearchViewController: SearchListViewDelegate {
    func selected(id: Int) {
        searchDelegate?.didSelectItem(id: id)
    }
}
