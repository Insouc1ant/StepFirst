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
    var activeStepTarget: Int = 0
    var activeAllowanceMinutes: Int = 30
    var secondsRemaining: Int = 1800
    var baselineSteps: Int = 0
    var isBaselineReady: Bool = false
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
        syncFromStorage()
    }
    
    func syncFromStorage() {
        let currentLocked = appGroupDefaults?.bool(forKey: StorageKey.isLocked) ?? false
        let currentLockTime = appGroupDefaults?.double(forKey: StorageKey.lockActivatedAt) ?? 0
        let currentUsage = appGroupDefaults?.integer(forKey: StorageKey.usageToday) ?? 0
        
        let appGroupGoals = appGroupDefaults?.double(forKey: StorageKey.stepGoals) ?? 0
        let standardGoals = UserDefaults.standard.double(forKey: StorageKey.stepGoals)
        let effectiveGoals = appGroupGoals > 0 ? appGroupGoals : (standardGoals > 0 ? standardGoals : 200)
        stepGoals = effectiveGoals
        
        let appGroupTime = appGroupDefaults?.integer(forKey: StorageKey.timeEarned) ?? 0
        let standardTime = UserDefaults.standard.integer(forKey: StorageKey.timeEarned)
        let effectiveTime = appGroupTime > 0 ? appGroupTime : (standardTime > 0 ? standardTime : 30)
        timeEarned = effectiveTime
        
        let savedActiveAllowance = appGroupDefaults?.integer(forKey: StorageKey.activeAllowanceMinutes) ?? 0
        activeAllowanceMinutes = savedActiveAllowance > 0 ? savedActiveAllowance : effectiveTime
        
        let savedActiveTarget = appGroupDefaults?.integer(forKey: StorageKey.activeStepTarget) ?? 0
        activeStepTarget = savedActiveTarget
        
        secondsRemaining = UserDefaults.standard.integer(forKey: StorageKey.secondsRemaining)
        baselineSteps = UserDefaults.standard.integer(forKey: StorageKey.baselineSteps)
        initialUsage = UserDefaults.standard.double(forKey: StorageKey.initialUsage)
        usageToday = currentUsage
        
        if UserDefaults.standard.object(forKey: StorageKey.hasSetInitialUsage) != nil {
            hasSetInitialUsage = UserDefaults.standard.bool(forKey: StorageKey.hasSetInitialUsage)
        } else {
            hasSetInitialUsage = true
        }
        
        if let loadedSelection = screenTimeManager.loadSelection() {
            selectedApps = loadedSelection
        }
        
        let lockStateChanged = (self.lockStatus != currentLocked)
        self.lockStatus = currentLocked
        self.lockActivatedAt = currentLockTime
        
        if currentLocked {
            if activeStepTarget == 0 {
                activeStepTarget = Int(stepGoals)
                appGroupDefaults?.set(activeStepTarget, forKey: StorageKey.activeStepTarget)
            }
            if lockStateChanged || baselineSteps == 0 {
                refreshBaselineStepsForCurrentLock()
            }
        } else {
            activeStepTarget = 0
            baselineSteps = 0
            isBaselineReady = true
        }
        
        recalculateAllowance()
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
        guard isBaselineReady else { return 0 }
        return max(0, liveSteps - baselineSteps)
    }
    
    var stepTarget: Int {
        if lockStatus && activeStepTarget > 0 {
            return activeStepTarget
        }
        return Int(stepGoals)
    }
    
    var currentAllowanceMinutes: Int {
        activeAllowanceMinutes > 0 ? activeAllowanceMinutes : timeEarned
    }
    
    var allowanceSeconds: Int {
        currentAllowanceMinutes * 60
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
        syncFromStorage()
        stepManager.startTracking()

        if !lockStatus {
            deviceActivityManager.startMonitoring(timeLimitMinutes: timeEarned)
        }
    }
    
    func refreshDashboard() {
        syncFromStorage()
    }
    
    func handleLockStatusChange(isLocked: Bool) {
        lockStatus = isLocked
        appGroupDefaults?.set(isLocked, forKey: StorageKey.isLocked)
        
        if isLocked {
            let now = Date().timeIntervalSince1970
            lockActivatedAt = now
            activeStepTarget = Int(stepGoals)
            appGroupDefaults?.set(now, forKey: StorageKey.lockActivatedAt)
            appGroupDefaults?.set(activeStepTarget, forKey: StorageKey.activeStepTarget)
            secondsRemaining = 0
            UserDefaults.standard.set(0, forKey: StorageKey.secondsRemaining)
            refreshBaselineStepsForCurrentLock()
        } else {
            baselineSteps = 0
            lockActivatedAt = 0
            activeStepTarget = 0
            isBaselineReady = true
            activeAllowanceMinutes = timeEarned
            UserDefaults.standard.set(0, forKey: StorageKey.baselineSteps)
            appGroupDefaults?.set(0, forKey: StorageKey.lockActivatedAt)
            appGroupDefaults?.set(0, forKey: StorageKey.activeStepTarget)
            appGroupDefaults?.set(timeEarned, forKey: StorageKey.activeAllowanceMinutes)
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
        // If an allowance is currently running, it continues with activeAllowanceMinutes.
        // The new timeEarned takes effect on the next unlock cycle.
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
            if stepManager.liveSteps > 0 {
                baselineSteps = stepManager.liveSteps
                UserDefaults.standard.set(baselineSteps, forKey: StorageKey.baselineSteps)
                isBaselineReady = true
                checkUnlockEligibility()
            }
            return
        }

        let lockDate = Date(timeIntervalSince1970: lockActivatedAt)
        isBaselineReady = false
        Task {
            let fetchedBaseline = await stepManager.stepsToday(upTo: lockDate)
            self.baselineSteps = fetchedBaseline
            UserDefaults.standard.set(fetchedBaseline, forKey: StorageKey.baselineSteps)
            self.isBaselineReady = true
            self.checkUnlockEligibility()
        }
    }
    
    func checkUnlockEligibility() {
        guard lockStatus else { return }
        guard isBaselineReady else { return }
        guard stepTarget > 0, currentSteps >= stepTarget else { return }

        // Unlock apps
        lockStatus = false
        baselineSteps = 0
        lockActivatedAt = 0
        activeStepTarget = 0
        isBaselineReady = true
        activeAllowanceMinutes = timeEarned
        
        appGroupDefaults?.set(false, forKey: StorageKey.isLocked)
        appGroupDefaults?.set(0, forKey: StorageKey.lockActivatedAt)
        appGroupDefaults?.set(0, forKey: StorageKey.activeStepTarget)
        appGroupDefaults?.set(timeEarned, forKey: StorageKey.activeAllowanceMinutes)
        UserDefaults.standard.set(0, forKey: StorageKey.baselineSteps)
        
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
