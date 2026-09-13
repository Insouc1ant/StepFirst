//
//  OnboardingViewModel.swift
//  StepFirst
//
//  Created by Ferdynand Kee on 13/09/26.
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    
    // MARK: - Constants & Storage
    private var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConfig.appGroupSuiteName)
    }
    
    // MARK: - Screen 1 State (App Restriction)
    var isPickerPresented: Bool = false
    var isRequestingPermission: Bool = false
    var selectedApps = FamilyActivitySelection()
    
    // MARK: - Screen 2 State (Goal & Reward Selection)
    var stepGoals: Double = 200
    var timeEarned: Int = 30
    
    // MARK: - Dependencies (Injectable Services)
    @ObservationIgnored private let screenTimeManager: ScreenTimeManager
    @ObservationIgnored private let deviceActivityManager: DeviceActivityManager
    @ObservationIgnored private let notificationManager: NotificationManager
    
    // MARK: - Computed Properties for Selected Apps UI
    var selectedCategoryTokens: [ActivityCategoryToken] {
        Array(selectedApps.categoryTokens)
    }

    var selectedApplicationTokens: [ApplicationToken] {
        Array(selectedApps.applicationTokens)
    }

    var totalSelectionsCount: Int {
        selectedCategoryTokens.count + selectedApplicationTokens.count
    }

    var hasValidSelection: Bool {
        totalSelectionsCount > 0
    }
    
    // MARK: - Initializer (Dependency Injection)
    init(
        screenTimeManager: ScreenTimeManager? = nil,
        deviceActivityManager: DeviceActivityManager? = nil,
        notificationManager: NotificationManager? = nil
    ) {
        self.screenTimeManager = screenTimeManager ?? .shared
        self.deviceActivityManager = deviceActivityManager ?? .shared
        self.notificationManager = notificationManager ?? .shared
    }
    
    // MARK: - Screen 1 Actions
    
    func requestPermissionsAndShowPicker() {
        guard !isRequestingPermission else { return }
        isRequestingPermission = true
        
        Task {
            do {
                // Request ScreenTime permission (only shows first time)
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                self.isPickerPresented = true
            } catch {
                print("Permission denied: \(error.localizedDescription)")
            }
            self.isRequestingPermission = false
        }
    }
    
    func updateSelectedApps(_ newSelection: FamilyActivitySelection) {
        selectedApps = newSelection
        screenTimeManager.saveSelection(newSelection)
    }
    
    // MARK: - Screen 2 Actions (Finish Onboarding)
    
    func completeOnboarding() {
        // 1. Ensure app selections are explicitly saved
        screenTimeManager.saveSelection(selectedApps)

        // 2. Save to App Group (for background extensions & widgets)
        appGroupDefaults?.set(Int(stepGoals), forKey: StorageKey.stepGoals)
        appGroupDefaults?.set(timeEarned, forKey: StorageKey.timeEarned)
        appGroupDefaults?.set(timeEarned, forKey: StorageKey.activeAllowanceMinutes)
        appGroupDefaults?.set(0, forKey: StorageKey.activeStepTarget)
        appGroupDefaults?.set(false, forKey: StorageKey.isLocked)
        appGroupDefaults?.set(0, forKey: StorageKey.lockActivatedAt)

        // 3. Save to Standard UserDefaults (for main app UI)
        UserDefaults.standard.set(stepGoals, forKey: StorageKey.stepGoals)
        UserDefaults.standard.set(timeEarned, forKey: StorageKey.timeEarned)
        UserDefaults.standard.set(timeEarned * 60, forKey: StorageKey.secondsRemaining)
        UserDefaults.standard.set(0, forKey: StorageKey.initialUsage)
        UserDefaults.standard.set(true, forKey: StorageKey.hasSetInitialUsage)
        UserDefaults.standard.set(0, forKey: StorageKey.baselineSteps)

        // 4. Start background monitoring
        deviceActivityManager.startMonitoring(timeLimitMinutes: timeEarned)

        // 5. Request notifications and flip the switch to open Dashboard
        notificationManager.requestPermission { _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: StorageKey.hasCompletedOnboarding)
            }
        }
    }
}
