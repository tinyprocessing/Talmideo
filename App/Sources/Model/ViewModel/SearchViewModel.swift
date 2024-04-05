import Foundation

public struct SearchViewModel: Decodable {
    public var result: [SearchWordModel] = []

    public init(result: [SearchWordModel]) {
        self.result = result
    }
}
