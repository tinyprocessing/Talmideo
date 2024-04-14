import Foundation

public struct SearchWordModel: Hashable, Decodable {
    public var id: Int
    public var form: String
    public var isBookmarked = false

    private var meaningRu: String
    private var meaningEn: String
    public var meaning: String {
        guard let appLanguage = Locale.preferredLanguages.first, appLanguage.hasPrefix("ru") else {
            return meaningEn
        }
        return meaningRu
    }

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

    static func fromID(dictionary: [String: Any?]) -> SearchWordModel? {
        guard let id = dictionary["id"] as? Int,
              let form = dictionary["initial_form"] as? String,
              let meaningRu = dictionary["meaning_ru"] as? String,
              let meaningEn = dictionary["meaning_en"] as? String
        else {
            return nil
        }
        return SearchWordModel(id: id, form: form, meaningRu: meaningRu, meaningEn: meaningEn)
    }
}
