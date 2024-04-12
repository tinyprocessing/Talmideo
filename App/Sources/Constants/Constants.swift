import Foundation
import UIKit

enum Constants {
    static let CalibrationEndpointUrl = "https://tinyprocessing.com"
    static let UnauthorizedErrorCodeRange = 401...403
    static let ServerTimeoutMin = 60
    static let InitialRouteType: RouteType = .home
    static let DefaultAnimationDuration = 0.3

    static let Dictionary = "database"
    static let DictionaryTranslator = "index"
    static let WordDataTable = "worddata"
    static let WordData = "word"
    static let backgroundColor = UIColor(hex: "F5F8FA")
}
