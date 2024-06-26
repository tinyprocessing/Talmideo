import Foundation

enum LocalizedString: String {
    case search
    case explore
    case settings
    case masculine
    case feminine
    case present
    case passivePresent
    case past
    case future
    case imperative
    case passiveFuture
    case passivePast
    case noun
    case adjective
    case pronoun
    case startLearning
    case nouns
    case verbs
    case adjectives

    // MARK: Settings

    case generalSettings
    case generalStatistics
    case bookmarks
    case github
    case website
    case mail
    case clearHistory
    case notifications
    case contact
    case advancedSettings
    case autoSpeech
    case sounds

    // MARK: Global

    case open
    case close
    case send
    case delete
    case next
    case `repeat`

    // MARK: Notifications

    case remember
    case markedWord

    // MARK: Onboarding

    case onboardingSearchTitle
    case onboardingExploreTitle
    case onboardingSwipeTitle
    case onboardingSearchContent
    case onboardingExploreContent
    case onboardingSwipeContent
}

extension String {
    static func localized(_ string: LocalizedString) -> String {
        return NSLocalizedString(string.rawValue,
                                 tableName: "Localizable",
                                 bundle: .main,
                                 value: string.rawValue,
                                 comment: string.rawValue)
    }
}
