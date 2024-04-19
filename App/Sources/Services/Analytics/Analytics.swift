import FirebaseAnalytics
import Foundation

protocol AnalyticsManager {
    func trackEvent(with module: TalmideoAnalytics.Module, event: TalmideoAnalytics.EventName)
}

public final class TalmideoAnalytics: AnalyticsManager {
    private var id = ""
    private var version = ""

    init() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.version = version
        }
        id = generateUserIDIfNeeded()
    }

    func trackEvent(with module: TalmideoAnalytics.Module, event: TalmideoAnalytics.EventName) {
        Analytics.logEvent(module.rawValue.rawValue, parameters: [
            "userID": id,
            "version": version,
            "eventName": event.rawValue.rawValue,
            "module": module.rawValue.rawValue
        ])
    }

    private func generateUserIDIfNeeded() -> String {
        if let userID = UserDefaults.standard.string(forKey: Config.key) {
            return userID
        } else {
            let userID = UUID().uuidString
            UserDefaults.standard.set(userID, forKey: Config.key)
            return userID
        }
    }

    private enum Config {
        static let key = "userID"
    }
}

extension TalmideoAnalytics {
    enum Module: AnalyticsValue {
        case search
        case app
        case bookmarks
        case explore
        case settings
    }

    enum EventName: AnalyticsValue {
        case onboardingStart
        case databaseStart
        case onboardingFinish
        case searchStart
        case search
        case searchText
        case searchFinish
        case exploreStart
        case exploreFinish
        case swipe
        case bookmarksRemove
        case bookmarsAdd
        case bookmarks
        case bookmardsRemoveItem
    }
}

public struct AnalyticsValue: AnalyticsString {
    public var rawValue: String
    public init(stringLiteral value: String) {
        rawValue = value
    }

    public static let null: AnalyticsValue = "(null)"
}

public protocol AnalyticsString: ExpressibleByStringLiteral, CustomStringConvertible, Hashable, Encodable {
    var rawValue: String { get set }
}

extension AnalyticsString {
    public var description: String {
        return rawValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
