import Foundation
import UIKit

protocol SearchHeaderDelegate: AnyObject {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
}

class SearchHeaderView: UIView {
    weak var delegate: SearchHeaderDelegate?

    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .minimal
        view.placeholder = Config.searchBarPlaceholder
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Config.backgroundColor
        view.layer.cornerRadius = 50
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        addSubview(backgroundView)
        backgroundView.addSubview(searchBar)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: -Config.backgroundViewPadding),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -Config.backgroundViewPadding),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Config.backgroundViewPadding)
        ])

        NSLayoutConstraint.activate([
            searchBar.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Config.searchBarPadding),
            searchBar.leadingAnchor.constraint(
                equalTo: backgroundView.leadingAnchor,
                constant: Config.searchBarPadding
            ),
            searchBar.trailingAnchor.constraint(
                equalTo: backgroundView.trailingAnchor,
                constant: -Config.searchBarPadding
            )
        ])
    }

    private enum Config {
        static let searchBarPaddingTop: CGFloat = 60
        static let searchBarPadding: CGFloat = 30
        static let searchBarPlaceholder = "Search"
        static let backgroundViewPadding: CGFloat = 16
        static let backgroundColor = UIColor(hex: "B4DDD3")
    }
}

extension SearchHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar(searchBar, textDidChange: searchText)
    }
}
