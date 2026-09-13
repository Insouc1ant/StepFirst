import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    // 1. The shared instance
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // 🔔 CRITICAL: This enables notifications to display banner & play sound even when the app is OPEN!
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    // 2. Ask the user for permission to send alerts
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted!")
            } else if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
            completion?(granted)
        }
    }
    
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // 3. The function to actually send a message
    func scheduleNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default // Plays the standard iPhone "ding"
        
        // Trigger the notification almost immediately (1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Send it to the iOS system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
