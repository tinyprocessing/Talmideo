import Foundation

enum LocalizedString: String {
    case search
    case explore
    case settings
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
