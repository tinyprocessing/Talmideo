import Foundation
import UIKit

protocol SearchHeaderDelegate: AnyObject {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    func bookmarkTap(isOn: Bool)
}

class SearchHeaderView: UIView {
    weak var delegate: SearchHeaderDelegate?

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo")
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = Config.searchBarPlaceholder
        view.clearBackgroundColor()
        view.textField?.backgroundColor = .white
        view.textField?.layer.cornerRadius = 15
        view.textField?.layer.masksToBounds = true
        view.setLeftImage(UIImage(systemName: "magnifyingglass") ?? UIImage(),
                          with: 5,
                          tintColor: .secondaryLabel)
        view.searchBarStyle = .default
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Config.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()

    private lazy var bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Config.iconStar, for: .normal)
        button.tintColor = .white
        button.backgroundColor = Config.buttonColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        backgroundView.addSubview(imageView)
        backgroundView.addSubview(searchBar)
        backgroundView.addSubview(bookmarkButton)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            searchBar.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            searchBar.leadingAnchor.constraint(
                equalTo: backgroundView.leadingAnchor,
                constant: Config.searchBarPadding
            ),
            searchBar.trailingAnchor.constraint(
                equalTo: backgroundView.trailingAnchor,
                constant: -Config.searchBarPadding
            ),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 30),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 30),
            bookmarkButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16)
        ])
    }

    @objc private func bookmarkButtonTapped() {
        if bookmarkButton.imageView?.image == Config.iconStar {
            bookmarkButton.setImage(Config.iconStarFill, for: .normal)
            searchBar.text = ""
            toggleSearchBarAvailability(false)
            delegate?.bookmarkTap(isOn: true)
        } else {
            bookmarkButton.setImage(Config.iconStar, for: .normal)
            toggleSearchBarAvailability(true)
            delegate?.bookmarkTap(isOn: false)
        }
    }

    private func toggleSearchBarAvailability(_ isEnabled: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.searchBar.alpha = isEnabled ? 1.0 : 0.5
            self.searchBar.isUserInteractionEnabled = isEnabled
        }
    }

    private enum Config {
        static let searchBarPaddingTop: CGFloat = 60
        static let searchBarPadding: CGFloat = 20
        static let searchBarPlaceholder: String = .localized(.search)
        static let backgroundViewPadding: CGFloat = 16
        static let backgroundColor = UIColor(hex: "B4DDD3")
        static let buttonColor = UIColor.secondaryLabel.withAlphaComponent(0.2)
        static var iconStar: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
            return UIImage(systemName: "star", withConfiguration: config) ?? UIImage()
        }

        static var iconStarFill: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
            return UIImage(systemName: "star.fill", withConfiguration: config) ?? UIImage()
        }
    }
}

extension SearchHeaderView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBar(searchBar, textDidChange: searchText)
    }
}
