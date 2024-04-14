import Foundation
import UIKit

enum CustomFont: String {
    case robotoSlabMedium = "RobotoSlab-Medium"
    case robotoSlabRegular = "RobotoSlab-Regular"
}

extension UIFont {
    static func customFont(_ font: CustomFont, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: font.rawValue, size: size) else {
            fatalError("Failed to load font: \(font.rawValue)")
        }
        return customFont
    }
}
