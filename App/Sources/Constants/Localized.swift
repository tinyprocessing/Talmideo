import Foundation

enum LocalizedString: String {
    case close
}

protocol Localized {}

extension Localized {
    func localized(string: LocalizedString) -> String {
        return string.rawValue
    }
}
