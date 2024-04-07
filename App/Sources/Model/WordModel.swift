import Foundation

struct WordModel: Codable {
    let binyan: String?
    let forms: Forms?
    let gender: String?
    let initialForm: InitialForm?
    let meaning: Meaning?
    let mishkal, partOfSpeech: String?
    let root: [String]?

    enum CodingKeys: String, CodingKey {
        case binyan, forms, gender
        case initialForm = "initial_form"
        case meaning, mishkal
        case partOfSpeech = "part_of_speech"
        case root
    }

    init(
        binyan: String? = nil,
        forms: Forms? = nil,
        gender: String? = nil,
        initialForm: InitialForm? = nil,
        meaning: Meaning? = nil,
        mishkal: String? = nil,
        partOfSpeech: String? = nil,
        root: [String]? = nil
    ) {
        self.binyan = binyan
        self.forms = forms
        self.gender = gender
        self.initialForm = initialForm
        self.meaning = meaning
        self.mishkal = mishkal
        self.partOfSpeech = partOfSpeech
        self.root = root
    }
}

struct Forms: Codable {
    let main: Main?
    let pPronoun, sPronoun: [String: InitialForm]?
    let smichut: Main?
    let future, imperative, passiveFuture, passivePast: [String: InitialForm]?
    let passivePresent: Present?
    let past: [String: InitialForm]?
    let present: Present?

    enum CodingKeys: String, CodingKey {
        case main
        case pPronoun = "p+pronoun"
        case sPronoun = "s+pronoun"
        case smichut
        case future, imperative
        case passiveFuture = "passive-future"
        case passivePast = "passive-past"
        case passivePresent = "passive-present"
        case past, present
    }
}

struct Main: Codable {
    let p, s, fp, fs, mp, ms: InitialForm?
}

struct InitialForm: Codable {
    let transcriptionEn, transcriptionEs, transcriptionRu, value: String?

    enum CodingKeys: String, CodingKey {
        case transcriptionEn = "transcription_en"
        case transcriptionEs = "transcription_es"
        case transcriptionRu = "transcription_ru"
        case value
    }
}

struct Meaning: Codable {
    let en, es, ru: String?
}

struct Present: Codable {
    let fp, fs, mp, ms: InitialForm?
}
