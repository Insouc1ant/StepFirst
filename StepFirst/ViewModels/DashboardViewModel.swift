//
//  DashboardViewModel.swift
//  StepFirst
//
//  Created by Ferdynand Kee on 11/09/26.
//

import Foundation
internal import Combine
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    // MARK: - App Group & Storage
    private var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConfig.appGroupSuiteName)
    }
    
    // MARK: - Published State (What the View Observes)
    var lockStatus: Bool = false
    var usageToday: Int = 0
    var lockActivatedAt: Double = 0
    var stepGoals: Double = 200
    var timeEarned: Int = 30
    var secondsRemaining: Int = 1800
    var baselineSteps: Int = 0
    var initialUsage: Double = 0
    var hasSetInitialUsage: Bool = true
    var liveSteps: Int = 0
    var selectedApps = FamilyActivitySelection()
    
    // MARK: - Dependencies (Injectable Services)
    let stepManager: StepTrackingService
    let screenTimeManager: ScreenTimeManager
    let deviceActivityManager: DeviceActivityManager
    let notificationManager: NotificationManager
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer (Dependency Injection & MainActor Safe)
    init(
        stepManager: StepTrackingService? = nil,
        screenTimeManager: ScreenTimeManager? = nil,
        deviceActivityManager: DeviceActivityManager? = nil,
        notificationManager: NotificationManager? = nil
    ) {
        self.stepManager = stepManager ?? StepManager()
        self.screenTimeManager = screenTimeManager ?? .shared
        self.deviceActivityManager = deviceActivityManager ?? .shared
        self.notificationManager = notificationManager ?? .shared
        
        loadInitialState()
        bindStepManager()
    }
    private func loadInitialState() {
        lockStatus = appGroupDefaults?.bool(forKey: StorageKey.isLocked) ?? false
        usageToday = appGroupDefaults?.integer(forKey: StorageKey.usageToday) ?? 0
        lockActivatedAt = appGroupDefaults?.double(forKey: StorageKey.lockActivatedAt) ?? 0
        
        let savedGoals = UserDefaults.standard.double(forKey: StorageKey.stepGoals)
        stepGoals = savedGoals > 0 ? savedGoals : 200
        
        let savedTime = UserDefaults.standard.integer(forKey: StorageKey.timeEarned)
        timeEarned = savedTime > 0 ? savedTime : 30
        
        secondsRemaining = UserDefaults.standard.integer(forKey: StorageKey.secondsRemaining)
        baselineSteps = UserDefaults.standard.integer(forKey: StorageKey.baselineSteps)
        initialUsage = UserDefaults.standard.double(forKey: StorageKey.initialUsage)
        
        if UserDefaults.standard.object(forKey: StorageKey.hasSetInitialUsage) != nil {
            hasSetInitialUsage = UserDefaults.standard.bool(forKey: StorageKey.hasSetInitialUsage)
        } else {
            hasSetInitialUsage = true
        }
        
        if let loadedSelection = screenTimeManager.loadSelection() {
            selectedApps = loadedSelection
        }
    }
    
    private func bindStepManager() {
        stepManager.liveStepsPublisher
            .sink { [weak self] newSteps in
                guard let self = self else { return }
                self.liveSteps = newSteps
                self.checkUnlockEligibility()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties (Formats data for the View)
    var currentSteps: Int {
        max(0, liveSteps - baselineSteps)
    }
    
    var stepTarget: Int {
        Int(stepGoals)
    }
    
    var allowanceSeconds: Int {
        timeEarned * 60
    }
    
    var selectedCategoryTokens: [ActivityCategoryToken] {
        Array(selectedApps.categoryTokens)
    }
    
    var selectedApplicationTokens: [ApplicationToken] {
        Array(selectedApps.applicationTokens)
    }
    
    var totalSelectionsCount: Int {
        selectedCategoryTokens.count + selectedApplicationTokens.count
    }
    
    var hasRestrictedApps: Bool {
        totalSelectionsCount > 0
    }
    
    // MARK: - Business Logic & Intent Methods
    
    func onAppear() {
        selectedApps = screenTimeManager.loadSelection() ?? FamilyActivitySelection()
        stepManager.startTracking()
        recalculateAllowance()

        if lockStatus {
            refreshBaselineStepsForCurrentLock()
        } else {
            deviceActivityManager.startMonitoring(timeLimitMinutes: timeEarned)
        }
    }
    
    func refreshDashboard() {
        selectedApps = screenTimeManager.loadSelection() ?? FamilyActivitySelection()
        recalculateAllowance()
        if lockStatus {
            refreshBaselineStepsForCurrentLock()
        }
    }
    
    func handleLockStatusChange(isLocked: Bool) {
        lockStatus = isLocked
        appGroupDefaults?.set(isLocked, forKey: StorageKey.isLocked)
        
        if isLocked {
            secondsRemaining = 0
            UserDefaults.standard.set(0, forKey: StorageKey.secondsRemaining)
            refreshBaselineStepsForCurrentLock()
        } else {
            baselineSteps = 0
            lockActivatedAt = 0
            UserDefaults.standard.set(0, forKey: StorageKey.baselineSteps)
            appGroupDefaults?.set(0, forKey: StorageKey.lockActivatedAt)
        }
    }
    
    func handleUsageChange(newUsage: Int) {
        usageToday = newUsage
        if hasSetInitialUsage && !lockStatus {
            initialUsage = Double(newUsage)
            hasSetInitialUsage = false
            UserDefaults.standard.set(initialUsage, forKey: StorageKey.initialUsage)
            appGroupDefaults?.set(initialUsage, forKey: StorageKey.initialUsage)
            UserDefaults.standard.set(false, forKey: StorageKey.hasSetInitialUsage)
        }
        recalculateAllowance()
    }
    
    func handleTimeEarnedChange(newTimeEarned: Int) {
        timeEarned = newTimeEarned
        UserDefaults.standard.set(newTimeEarned, forKey: StorageKey.timeEarned)
        appGroupDefaults?.set(newTimeEarned, forKey: StorageKey.timeEarned)
        recalculateAllowance()
        if !lockStatus {
            initialUsage = Double(usageToday)
            UserDefaults.standard.set(initialUsage, forKey: StorageKey.initialUsage)
            appGroupDefaults?.set(initialUsage, forKey: StorageKey.initialUsage)
            deviceActivityManager.startMonitoring(timeLimitMinutes: newTimeEarned)
        }
    }
    
    func recalculateAllowance() {
        guard !lockStatus else {
            secondsRemaining = 0
            UserDefaults.standard.set(0, forKey: StorageKey.secondsRemaining)
            return
        }
        let usedThisCycle = max(0, usageToday - Int(initialUsage))
        secondsRemaining = max(0, allowanceSeconds - usedThisCycle)
        UserDefaults.standard.set(secondsRemaining, forKey: StorageKey.secondsRemaining)
    }
    
    func refreshBaselineStepsForCurrentLock() {
        guard lockActivatedAt > 0 else {
            baselineSteps = stepManager.liveSteps
            UserDefaults.standard.set(baselineSteps, forKey: StorageKey.baselineSteps)
            checkUnlockEligibility()
            return
        }

        let lockDate = Date(timeIntervalSince1970: lockActivatedAt)
        Task {
            let fetchedBaseline = await stepManager.stepsToday(upTo: lockDate)
            self.baselineSteps = fetchedBaseline
            UserDefaults.standard.set(fetchedBaseline, forKey: StorageKey.baselineSteps)
            self.checkUnlockEligibility()
        }
    }
    
    func checkUnlockEligibility() {
        guard lockStatus else { return }
        guard stepTarget > 0, currentSteps >= stepTarget else { return }

        // Unlock apps
        lockStatus = false
        appGroupDefaults?.set(false, forKey: StorageKey.isLocked)
        
        initialUsage = Double(usageToday)
        UserDefaults.standard.set(initialUsage, forKey: StorageKey.initialUsage)
        appGroupDefaults?.set(initialUsage, forKey: StorageKey.initialUsage)
        
        hasSetInitialUsage = false
        UserDefaults.standard.set(false, forKey: StorageKey.hasSetInitialUsage)
        
        secondsRemaining = allowanceSeconds
        UserDefaults.standard.set(secondsRemaining, forKey: StorageKey.secondsRemaining)

        screenTimeManager.unlockApps()
        deviceActivityManager.startMonitoring(timeLimitMinutes: timeEarned)

        notificationManager.scheduleNotification(
            title: "Step Goals Reached! 🎯",
            body: "Great job! Your apps are unlocked for another \(timeEarned) minutes!"
        )
    }
}
