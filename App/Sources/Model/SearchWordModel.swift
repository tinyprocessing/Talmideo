import Foundation

public struct SearchWordModel: Decodable {
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

extension SearchWordModel {
    static func from(dictionary: [String: Any?]) -> SearchWordModel? {
        guard let id = dictionary["word_data_id"] as? Int,
              let form = dictionary["initial_form"] as? String,
              let meaningRu = dictionary["meaning_ru"] as? String,
              let meaningEn = dictionary["meaning_en"] as? String
        else {
            return nil
        }
        return SearchWordModel(id: id, form: form, meaningRu: meaningRu, meaningEn: meaningEn)
    }
}
