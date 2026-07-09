import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate { // 💡 NSObject සහ Delegate එක එකතු කළා
    static let shared = NotificationService()
    
    private override init() {
        super.init()
        // 
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print(granted ? " Notifications enabled" : " Notifications denied")
            if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDailyNotification(at time: Date) {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge! 🎯"
        content.body = "Play a game and beat your high score!"
        content.sound = .default
        
        // 💡 Hour සහ Minute විතරක් ගැනීම සෑහේ, තත්පර 00 කරමු ප්‍රශ්න මඟහරින්න
        var components = Calendar.current.dateComponents([.hour, .minute], from: time)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "dailyChallenge",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error)")
            } else {
                print("✅ Notification successfully scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
        print("🗑️ Pending notifications cancelled")
    }
    
    // 💡 මේ Method එකෙන් තමයි App එක Foreground එකේ (Open වෙලා) තිබ්බත් Notification එක උඩින් Dropdown එකක් විදිහට පෙන්වන්නේ
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound]) // iOS 14+ සඳහා .banner පාවිච්චි කරයි
    }
}
