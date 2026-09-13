import SwiftUI
import Foundation
import CoreMotion
internal import Combine

class StepManager: ObservableObject, StepTrackingService {
    private let pedometer = CMPedometer()
    @Published var liveSteps: Int = 0
    
    var liveStepsPublisher: AnyPublisher<Int, Never> {
        $liveSteps.eraseToAnyPublisher()
    }
    
    func startTracking() {
        // 1. Check if the device actually has a step counter
        guard CMPedometer.isStepCountingAvailable() else {
            print("Step counting is not available on this device.")
            return
        }
        
        // 2. Only track today's step
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        // 3. Start the live feed
        pedometer.startUpdates(from: startOfDay) { [weak self] pedometerData, error in
            guard let data = pedometerData, error == nil else {
                print("Error tracking steps: \(String(describing: error))")
                return
            }
            
            // 4. CoreMotion runs in the background, sPush UI updates to the Main thread
            DispatchQueue.main.async {
                self?.liveSteps = data.numberOfSteps.intValue
            }
        }
    }
    
    func stopTracking() {
        pedometer.stopUpdates()
    }

    func stepsToday(upTo date: Date) async -> Int {
        guard CMPedometer.isStepCountingAvailable() else {
            return 0
        }

        let startOfDay = Calendar.current.startOfDay(for: date)

        return await withCheckedContinuation { continuation in
            pedometer.queryPedometerData(from: startOfDay, to: date) { data, error in
                guard let data, error == nil else {
                    continuation.resume(returning: 0)
                    return
                }

                continuation.resume(returning: data.numberOfSteps.intValue)
            }
        }
    }
}

@MainActor
final class UnlockManager {
    static let shared = UnlockManager()

    private let stepManager = StepManager()
    private let appGroupDefaults = UserDefaults(suiteName: AppConfig.appGroupSuiteName)
    private var isCheckingUnlock = false

    private init() {}

    func checkForUnlockIfNeeded() async {
        guard !isCheckingUnlock else { return }
        guard appGroupDefaults?.bool(forKey: StorageKey.isLocked) == true else { return }

        let lockActivatedAt = appGroupDefaults?.double(forKey: StorageKey.lockActivatedAt) ?? 0
        guard lockActivatedAt > 0 else { return }

        isCheckingUnlock = true
        defer { isCheckingUnlock = false }

        let stepGoal = Int(UserDefaults.standard.double(forKey: StorageKey.stepGoals))
        guard stepGoal > 0 else { return }

        let lockDate = Date(timeIntervalSince1970: lockActivatedAt)
        let stepsAtLock = await stepManager.stepsToday(upTo: lockDate)
        let currentSteps = await stepManager.stepsToday(upTo: Date())
        let walkedSinceLock = max(0, currentSteps - stepsAtLock)

        guard walkedSinceLock >= stepGoal else { return }

        let timeEarned = UserDefaults.standard.integer(forKey: StorageKey.timeEarned)
        let selectedAppsUsageToday = appGroupDefaults?.integer(forKey: StorageKey.usageToday) ?? 0

        appGroupDefaults?.set(false, forKey: StorageKey.isLocked)
        appGroupDefaults?.set(0, forKey: StorageKey.lockActivatedAt)
        UserDefaults.standard.set(0, forKey: StorageKey.baselineSteps)
        UserDefaults.standard.set(Double(selectedAppsUsageToday), forKey: StorageKey.initialUsage)
        appGroupDefaults?.set(Double(selectedAppsUsageToday), forKey: StorageKey.initialUsage)
        UserDefaults.standard.set(false, forKey: StorageKey.hasSetInitialUsage)
        UserDefaults.standard.set(timeEarned * 60, forKey: StorageKey.secondsRemaining)

        ScreenTimeManager.shared.unlockApps()
        DeviceActivityManager.shared.startMonitoring(timeLimitMinutes: timeEarned)
        NotificationManager.shared.scheduleNotification(
            title: "Step Goals Reached! 🎯",
            body: "Great job! Your apps are unlocked for another \(timeEarned) minutes!"
        )
    }
}
