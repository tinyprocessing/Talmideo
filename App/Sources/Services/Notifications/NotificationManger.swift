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
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }

    public func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    public func scheduleNotificationsForToday(newWords: [Word]) {
        removeAllNotifications()

        let currentDate = Date()
        let calendar = Calendar.current

        let notificationTimes: [Int] = [10, 13, 19]

        let notificationsToSchedule = min(newWords.count, notificationTimes.count)

        for (index, word) in newWords.prefix(notificationsToSchedule).enumerated() {
            var components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = notificationTimes[index]

            if let notificationDate = calendar.date(from: components), notificationDate > currentDate {
                scheduleNotificationForWord(word: word, date: notificationDate)
            } else {
                components.day! += 1
                components.hour = notificationTimes[index]
                let nextDayNotificationDate = calendar.date(from: components)!
//                let currentDate = Date()
//                let testDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
                scheduleNotificationForWord(word: word, date: nextDayNotificationDate)
                print("shedule new notification in - ", nextDayNotificationDate, "with this data - ", word)
            }
        }
    }

    private func scheduleNotificationForWord(word: Word, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "New Word!"
        content.body = "Learn a new word: \(word.text) - \(word.definition)"
        content.sound = .default

        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        print(trigger)

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
}
