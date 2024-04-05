import Foundation

public struct SearchViewModel: Decodable {
    public var result: [WordModel] = []

    public init(result: [WordModel]) {
        self.result = result
    }
}
