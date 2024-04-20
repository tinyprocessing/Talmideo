import Foundation
import UserNotifications

class LocalNotificationManager {
    static let shared = LocalNotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()

    struct Word {
        let id: String
        let text: String
        let definition: String
    }

    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }

    public func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    public func scheduleNotifications(words: [Word]) async {
        if !CacheManager.shared.getNotifications() {
            return
        }

        removeAllNotifications()

        let calendar = Calendar.current
        let timezone = TimeZone.current

        var dateComponents = calendar.dateComponents(in: timezone, from: Date())
        dateComponents.hour = 10
        dateComponents.minute = 0
        dateComponents.second = 0

        var notificationIndex = 0
        var daysToAdd = 0
        for word in words {
            var notificationDate = calendar.date(from: dateComponents)!
            notificationDate = calendar.date(byAdding: .day, value: daysToAdd, to: notificationDate)!
            notificationDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: notificationDate)!
            switch notificationIndex % 3 {
            case 1:
                notificationDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: notificationDate)!
            case 2:
                notificationDate = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: notificationDate)!
            default:
                break
            }
            scheduleNotificationForWord(word: word, date: notificationDate)
            notificationIndex += 1

            if notificationIndex % 3 == 0 {
                daysToAdd += 1
            }
        }
    }

    private func scheduleNotificationForWord(word: Word, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = .localized(.remember)
        content.body = String(format: .localized(.markedWord), word.text, word.definition)
        content.sound = .default

        let triggerDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: word.id, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification for word \(word.text): \(error)")
            }
        }
    }

    private func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    private enum Config {
        static let settingsNotifications = "notifications"
    }
}
