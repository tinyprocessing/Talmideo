import AVFoundation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AVSpeechSynthesizer.shared.speak("", language: "en")
        LocalNotificationManager.shared.requestAuthorization { granted in
            if granted {
                let words: [LocalNotificationManager.Word] = [
                    .init(id: "1", text: "hello world", definition: "this is new word")
                ]
                LocalNotificationManager.shared.scheduleNotificationsForToday(newWords: words)
            } else {
                print("Notification authorization denied")
            }
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
