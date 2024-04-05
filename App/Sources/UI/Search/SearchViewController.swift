import Combine
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchBar(textDidChange searchText: String)
}

class SearchViewController: BaseViewController {
    var searchDelegate: SearchViewControllerDelegate?

    private var model: CurrentValueSubject<SearchViewModel, Never>
    private var cancellables = Set<AnyCancellable>()

    private lazy var searchHeader: SearchHeaderView = {
        let view = SearchHeaderView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var searchList: SearchListView = {
        let view = SearchListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(searchDelegate: SearchViewControllerDelegate? = nil, model: CurrentValueSubject<SearchViewModel, Never>) {
        self.searchDelegate = searchDelegate
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
        hideKeyboardWhenTappedAround()

        view.backgroundColor = Config.backgroundColor
        view.addSubview(searchHeader)
        view.addSubview(searchList)

        model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.update()
            }
            .store(in: &cancellables)

        NSLayoutConstraint.activate([
            searchHeader.topAnchor.constraint(equalTo: view.topAnchor),
            searchHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchHeader.heightAnchor.constraint(equalToConstant: Config.searchHeaderHeight)
        ])

        NSLayoutConstraint.activate([
            searchList.topAnchor.constraint(equalTo: searchHeader.bottomAnchor, constant: Config.searchListPaddingTop),
            searchList.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Config.searchListPaddingTop
            ),
            searchList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Config.searchListPadding),
            searchList.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Config.searchListPadding)
        ])
    }

    // MARK: Actions

    private func update() {
        var array: [(String, String)] = []
        model.value.result.forEach { word in
            array.append((word.meaningRu, word.form))
        }
        searchList.refreshWithData(array)
    }

    private enum Config {
        static let backgroundColor = UIColor(hex: "F5F8FA")
        static let searchHeaderHeight: CGFloat = 150
        static let searchListPadding: CGFloat = 10
        static let searchListPaddingTop: CGFloat = 20
    }
}

extension SearchViewController: SearchHeaderDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDelegate?.searchBar(textDidChange: searchText)
    }
}
