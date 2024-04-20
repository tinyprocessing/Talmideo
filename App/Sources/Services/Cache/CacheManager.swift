import Foundation

class CacheManager {
    static let shared = CacheManager()

    private let fileURL: URL
    private var settings: Settings

    struct Settings: Codable {
        var notifications = false
        var sounds = true
        var autoSpeech = false
    }

    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("settings.json")

        if let data = try? Data(contentsOf: fileURL),
           let decodedSettings = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decodedSettings
        } else {
            settings = Settings()
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    // MARK: - Setting Accessors

    func setNotifications(_ enabled: Bool) {
        settings.notifications = enabled
        save()
    }

    func getNotifications() -> Bool {
        return settings.notifications
    }

    func setAutoSpeech(_ enabled: Bool) {
        settings.autoSpeech = enabled
        save()
    }

    func getAutoSpeech() -> Bool {
        return settings.autoSpeech
    }

    func setSounds(_ enabled: Bool) {
        settings.sounds = enabled
        save()
    }

    func getSounds() -> Bool {
        return settings.sounds
    }
}
