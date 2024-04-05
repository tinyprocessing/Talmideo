import Foundation

public struct WordModel: Decodable {
    public var id: Int
    public var form: String
    public var meaningRu: String
    public var meaningEn: String

    public init(id: Int, form: String, meaningRu: String, meaningEn: String) {
        self.id = id
        self.form = form
        self.meaningRu = meaningRu
        self.meaningEn = meaningEn
    }
}

extension WordModel {
    static func from(dictionary: [String: Any?]) -> WordModel? {
        guard let id = dictionary["id"] as? Int,
              let form = dictionary["initial_form"] as? String,
              let meaningRu = dictionary["meaning_ru"] as? String,
              let meaningEn = dictionary["meaning_en"] as? String
        else {
            return nil
        }
        return WordModel(id: id, form: form, meaningRu: meaningRu, meaningEn: meaningEn)
    }
}
