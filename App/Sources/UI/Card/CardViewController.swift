import Combine
import UIKit

protocol CardViewControllerDelegate: AnyObject {
    func addCards()
    func swipe()
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
        button.setTitle(.localized(.next), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.shadowColor = Config.buttonNextColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.7
        button.backgroundColor = Config.buttonNextColor
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.customFont(.robotoSlabRegular, size: 18)
        return button
    }()

    private lazy var cardTimerView: CardTimerView = {
        let view = CardTimerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        view.addSubview(nextButton)
        view.addSubview(cardTimerView)
        view.addSubview(cardStack)

        cardStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardTimerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            cardTimerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            cardTimerView.heightAnchor.constraint(equalToConstant: 40),
            cardTimerView.widthAnchor.constraint(equalToConstant: 100)
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
        let old = cards.count
        cards.append(contentsOf: model.value)
        let new = cards.count
        let indices = Array(old..<new)
        cardStack.appendCards(atIndices: indices)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func nextButtonTapped() {
        cardStack.swipe(.left, animated: true)
    }

    private enum Config {
        static let buttonColor = UIColor(hex: "FFC75A")
        static let buttonNextColor = UIColor.secondaryLabel.withAlphaComponent(0.05)
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
        cardDelegate?.swipe()
        if (cards.count - index) < 3 {
            cardDelegate?.addCards()
        }
        if CacheManager.shared.getAutoSpeech() {
            (cardStack.topCard?.content as? CardContentView)?.soundButtonTapped()
        }
    }
}
