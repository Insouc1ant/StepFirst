//
//  DeviceActivityMonitorExtension.swift
//  AppMonitorExtension
//
//  Created by Ferdynand Kee on 27/04/26.
//

import DeviceActivity
import FamilyControls
import ManagedSettings
import Foundation
import UserNotifications

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()
    private let appGroupSuiteName = "group.com.kee.StepFirst"
    private let savedAppTokensKey = "SavedAppTokens"
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Handle the start of the interval.
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold: re-apply the shield to lock the apps.
        guard let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName),
              let data = sharedDefaults.data(forKey: savedAppTokensKey),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            print("No saved app selection found to shield.")
            return
        }
        
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        // Update lock status for the main app UI and widget
        sharedDefaults.set(true, forKey: "isLocked")
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: "lockActivatedAt")
        
        print("Threshold reached for \(event.rawValue) — apps re-locked.")
        
        // Send a notification that screen time is up and apps are locked
        sendLockNotification(sharedDefaults: sharedDefaults)
    }
    
    private func sendLockNotification(sharedDefaults: UserDefaults) {
        let content = UNMutableNotificationContent()
        content.title = "Screen Time is Up! 🔒"
        let stepGoals = sharedDefaults.integer(forKey: "stepGoals")
        if stepGoals > 0 {
            content.body = "Your apps are now locked. Walk \(stepGoals) steps to unlock them!"
        } else {
            content.body = "Your restricted apps are now locked. Walk to reach your step goal and unlock them!"
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule lock notification: \(error.localizedDescription)")
            }
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
