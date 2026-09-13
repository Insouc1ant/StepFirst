//
//  ShieldActionExtension.swift
//  AppShieldAction
//
//  Created by Ferdynand Kee on 03/09/26.
//

import ManagedSettings
import CoreMotion
import DeviceActivity
import FamilyControls
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    private let pedometer = CMPedometer()
    private let appGroupSuiteName = "group.com.kee.StepFirst"

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action, completionHandler: completionHandler)
    }

    private func handleAction(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            checkStepsAndHandle(completionHandler: completionHandler)
        default:
            completionHandler(.close)
        }
    }

    private func checkStepsAndHandle(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupSuiteName) else {
            completionHandler(.close)
            return
        }

        let stepGoals = sharedDefaults.integer(forKey: "stepGoals")
        let effectiveStepGoals = stepGoals > 0 ? stepGoals : 200
        let timeEarned = sharedDefaults.integer(forKey: "timeEarned")
        let effectiveTimeEarned = timeEarned > 0 ? timeEarned : 30
        let lockActivatedAt = sharedDefaults.double(forKey: "lockActivatedAt")

        guard CMPedometer.isStepCountingAvailable() else {
            sendNotification(
                title: "Motion Not Available ⚠️",
                body: "Step counting is not accessible on this device."
            )
            completionHandler(.close)
            return
        }

        let startDate: Date
        if lockActivatedAt > 0 {
            startDate = Date(timeIntervalSince1970: lockActivatedAt)
        } else {
            startDate = Calendar.current.startOfDay(for: Date())
        }

        pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, error in
            guard let self = self else {
                completionHandler(.close)
                return
            }

            let walkedSteps = data?.numberOfSteps.intValue ?? 0

            if walkedSteps >= effectiveStepGoals {
                // ✅ POSITIVE CASE: Goal reached! Unlock apps!
                self.unlockApps(
                    sharedDefaults: sharedDefaults,
                    walkedSteps: walkedSteps,
                    timeEarned: effectiveTimeEarned
                )
                completionHandler(.close)
            } else {
                // ❌ NEGATIVE CASE: Still need more steps
                let remaining = max(1, effectiveStepGoals - walkedSteps)
                self.sendNotification(
                    title: "Keep Going! 👟",
                    body: "You've walked \(walkedSteps) of \(effectiveStepGoals) steps. Just \(remaining) more to unlock!"
                )
                completionHandler(.close)
            }
        }
    }

    private func unlockApps(sharedDefaults: UserDefaults, walkedSteps: Int, timeEarned: Int) {
        // 1. Remove shields from restricted apps
        let store = ManagedSettingsStore()
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        // 2. Update lock status in shared storage
        sharedDefaults.set(false, forKey: "isLocked")
        sharedDefaults.set(0, forKey: "lockActivatedAt")

        // 3. Restart monitoring for earned screen time
        restartMonitoring(timeLimitMinutes: timeEarned, sharedDefaults: sharedDefaults)

        // 4. Send celebration notification
        sendNotification(
            title: "Step Goals Reached! 🎯",
            body: "Great job! Your apps are unlocked for another \(timeEarned) minutes!"
        )
    }

    private func restartMonitoring(timeLimitMinutes: Int, sharedDefaults: UserDefaults) {
        guard let data = sharedDefaults.data(forKey: "SavedAppTokens"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        let event = DeviceActivityEvent(
            applications: selection.applicationTokens,
            categories: selection.categoryTokens,
            webDomains: selection.webDomainTokens,
            threshold: DateComponents(minute: timeLimitMinutes),
            includesPastActivity: false
        )

        let center = DeviceActivityCenter()
        let activityName = DeviceActivityName("DailyAppLimit")
        let eventName = DeviceActivityEvent.Name("TimeLimitReached")

        center.stopMonitoring([activityName])
        try? center.startMonitoring(activityName, during: schedule, events: [eventName: event])
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
