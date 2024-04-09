import Combine
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

    private lazy var nextButton: ActionButton = {
        let button = ActionButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("Next", for: .normal)
        button.tintColor = .white
        button.layer.shadowColor = Config.buttonColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.7
        button.backgroundColor = Config.buttonColor
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
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
        configure()

        model
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.update()
            }
            .store(in: &cancellables)
    }

    private func configure() {
        view.addSubview(backButton)
        view.addSubview(cardStack)
        view.addSubview(nextButton)

        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])

        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            cardStack.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            cardStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cardStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
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

    @objc private func nextButtonTapped() {
        cardStack.swipe(.left, animated: true)
    }

    private enum Config {
        static let buttonColor = UIColor(hex: "FFC75A")
        static var iconBack: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
            return UIImage(systemName: "chevron.left", withConfiguration: config) ?? UIImage()
        }

        static var nextBack: UIImage {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default)
            return UIImage(systemName: "arrow.right", withConfiguration: config) ?? UIImage()
        }
    }
}

extension CardViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = SwipeCard()
        card.swipeDirections = [.left, .up, .right]
        let model = cards[index]
        card.content = CardContentView(model)
        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cards.count
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        if (cards.count - index) < 3 {
            cardDelegate?.addCards()
        }
    }
}
