import Combine
import Shuffle
import UIKit

protocol CardViewControllerDelegate: AnyObject {
    func addCards()
}

class CardViewController: BaseViewController {
    var cardDelegate: CardViewControllerDelegate?

    private let cardStack = SwipeCardStack()
    private var model: CurrentValueSubject<[WordModel], Never>
    private var cancellables = Set<AnyCancellable>()
    private var cards: [WordModel] = []

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

    init(model: CurrentValueSubject<[WordModel], Never>) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        cardStack.delegate = self
        cardStack.dataSource = self
        cardStack.reloadData()
        layoutCardStackView()
        model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.update()
            }
            .store(in: &cancellables)
    }

    private func layoutCardStackView() {
        view.addSubview(backButton)
        view.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            cardStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cardStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func update() {
        if cards.isEmpty {
            cards = model.value
            cardStack.reloadData()
            return
        }

        let old = cards.count
        let new = old + model.value.count
        DispatchQueue.main.async { [self] in
            cards.append(contentsOf: model.value)
            let indices = Array(old..<new)
            cardStack.appendCards(atIndices: indices)
        }
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

extension CardViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: Shuffle.SwipeCardStack, cardForIndexAt index: Int) -> Shuffle.SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .up, .right]
        let model = cards[index]
        card.content = CardContentView(model)
        return card
    }

    func numberOfCards(in cardStack: Shuffle.SwipeCardStack) -> Int {
        return cards.count
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        if (cards.count - index) < 3 {
            cardDelegate?.addCards()
        }
    }
}
