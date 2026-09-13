import Foundation
import DeviceActivity
import FamilyControls

class DeviceActivityManager {
    static let shared = DeviceActivityManager()
    let center = DeviceActivityCenter()
    
    func startMonitoring(timeLimitMinutes: Int) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        guard let data = UserDefaults(suiteName: AppConfig.appGroupSuiteName)?.data(forKey: StorageKey.savedAppTokens),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            print("No apps saved to monitor.")
            return
        }
        
        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: timeLimitMinutes),
            includesPastActivity: false
        )
        
        let activityName = DeviceActivityName("DailyAppLimit")
        let eventName = DeviceActivityEvent.Name("TimeLimitReached")
        
        do {
            // 🚨 THE KILL SWITCH: Wipe old ghost schedules before starting a new one!
            center.stopMonitoring([activityName])
            
            try center.startMonitoring(activityName, during: schedule, events: [eventName: event])
            print("iOS background stopwatch started for \(timeLimitMinutes) minutes!")
        } catch {
            print("Failed to start monitoring: \(error.localizedDescription)")
        }
    }
    
    func stopMonitoring() {
        center.stopMonitoring()
        print("iOS background stopwatch stopped.")
    }
}
