import Foundation
import UIKit

protocol SearchListViewDelegate: AnyObject {
    func selected(id: Int)
}

class SearchListView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    weak var delegate: SearchListViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupStackView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
        setupStackView()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.keyboardDismissMode = .onDrag
        scrollView.addSubview(stackView)
        scrollView.alwaysBounceVertical = true

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    func refreshWithData(_ data: [(Int, String, String)]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for item in data {
            let cell = SearchCellView()
            cell.id = item.0
            cell.leftLabel.text = item.1
            cell.rightLabel.text = item.2
            cell.callback = { [weak self] id in
                self?.delegate?.selected(id: id)
            }
            stackView.addArrangedSubview(cell)
        }

        stackView.layoutIfNeeded()
    }
}
