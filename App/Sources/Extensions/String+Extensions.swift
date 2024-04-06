import Foundation
import UIKit

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }

    func highlightCharacterAfterSymbol(symbol: Character) -> NSAttributedString? {
        guard range(of: String(symbol)) != nil else {
            return nil
        }

        if let firstIndex = firstIndex(of: symbol) {
            let char = self.index(after: firstIndex)
            guard indices.contains(char) else {
                return nil
            }
            let attributedString = NSMutableAttributedString(string: self)

            let redAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red]
            attributedString.addAttributes(
                redAttributes,
                range: NSRange(location: distance(from: startIndex, to: char), length: 1)
            )

            let index: Int = distance(from: startIndex, to: firstIndex)
            attributedString.deleteCharacters(in: NSRange(location: index, length: 1))

            return attributedString
        }

        return nil
    }
}
