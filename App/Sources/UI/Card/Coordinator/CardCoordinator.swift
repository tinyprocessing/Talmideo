import Combine
import Foundation
import UIKit

class CardCoordinator: Coordinator<Void> {
    private let router: Router?
    private var viewController: CardViewController?
    private let database: SQLiteDataDatabase
    private let words: [Int]
    private var model: CurrentValueSubject<[WordModel], Never> = .init([])
    private let analytics: TalmideoAnalytics

    init?(router: Router?, databaseWord: SQLiteDataDatabase, words: [Int], analytics: TalmideoAnalytics) {
        self.router = router
        self.words = words
        self.analytics = analytics
        database = databaseWord
        viewController = CardViewController(model: model)
        super.init()
        update()
        viewController?.cardDelegate = self
    }

    private func update() {
        var array: [WordModel] = []
        getRandomWords().forEach { value in
            array.append(get(value))
        }
        model.send(array)
    }

    private func getRandomWords() -> [Int] {
        guard !words.isEmpty else { return [] }

        let randomIndices = Set((0..<words.count).shuffled().prefix(5))
        let randomWords = randomIndices.map { words[$0] }

        return randomWords
    }

    private func get(_ value: Int) -> WordModel {
        let query: (String, [Any?]) = database.query.prepare(.word(value: value))
        let result = database.search(query)
        var word = WordModel()
        result.forEach { value in
            if let data = value["data"] as? String {
                if let jsonData = data.data(using: .utf8) {
                    do {
                        word = try JSONDecoder().decode(WordModel.self, from: jsonData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
        }
        return word
    }

    override func start() {
        super.start()
    }

    public func exportViewController() -> BaseViewController {
        return viewController ?? BaseViewController()
    }
}

extension CardCoordinator: CardViewControllerDelegate {
    func addCards() {
        update()
    }

    func swipe() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        if CacheManager.shared.getSounds() {
            SoundManager.shared.playSoundEffect(.cardSwipeCalm)
        }
        analytics.trackEvent(with: .explore, event: .swipe)
    }
}
