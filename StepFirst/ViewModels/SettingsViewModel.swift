//
//  SettingsViewModel.swift
//  StepFirst
//
//  Created by Ferdynand Kee on 13/09/26.
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Constants & Storage
    private var appGroupDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConfig.appGroupSuiteName)
    }
    
    // MARK: - Observable State (Binds directly to UI Sliders & Pickers)
    var stepGoals: Double = 200
    var timeEarned: Int = 30
    var isPickerPresented: Bool = false
    var selectedApps = FamilyActivitySelection()
    
    // MARK: - Initial State Tracking (For detecting edits during active sessions)
    var initialStepGoals: Double = 200
    var initialTimeEarned: Int = 30
    var isLocked: Bool = false
    var activeStepTarget: Int = 0
    var activeAllowanceMinutes: Int = 0

    // MARK: - Dependencies
    @ObservationIgnored private let screenTimeManager: ScreenTimeManager
    
    // MARK: - Computed Properties for the UI List
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
    init(screenTimeManager: ScreenTimeManager? = nil) {
        self.screenTimeManager = screenTimeManager ?? .shared
        loadSettings()
    }
    
    // MARK: - Intent & Business Methods
    
    func loadSettings() {
        isLocked = appGroupDefaults?.bool(forKey: StorageKey.isLocked) ?? false
        activeStepTarget = appGroupDefaults?.integer(forKey: StorageKey.activeStepTarget) ?? 0
        activeAllowanceMinutes = appGroupDefaults?.integer(forKey: StorageKey.activeAllowanceMinutes) ?? 0

        // Load step goals (check App Group first, then Standard, then default to 200)
        let appGroupGoals = appGroupDefaults?.double(forKey: StorageKey.stepGoals) ?? 0
        let standardGoals = UserDefaults.standard.double(forKey: StorageKey.stepGoals)
        let effectiveGoals = appGroupGoals > 0 ? appGroupGoals : (standardGoals > 0 ? standardGoals : 200)
        stepGoals = effectiveGoals
        initialStepGoals = effectiveGoals
        
        // Load time earned (check App Group first, then Standard, then default to 30)
        let appGroupTime = appGroupDefaults?.integer(forKey: StorageKey.timeEarned) ?? 0
        let standardTime = UserDefaults.standard.integer(forKey: StorageKey.timeEarned)
        let effectiveTime = appGroupTime > 0 ? appGroupTime : (standardTime > 0 ? standardTime : 30)
        timeEarned = effectiveTime
        initialTimeEarned = effectiveTime
        
        // Load restricted apps selection from ScreenTimeManager
        if let savedSelection = screenTimeManager.loadSelection() {
            selectedApps = savedSelection
        }
    }
    
    func updateSelectedApps(_ newSelection: FamilyActivitySelection) {
        selectedApps = newSelection
        screenTimeManager.saveSelection(newSelection)
    }
    
    func saveSettings() {
        // 1. Save to Standard UserDefaults
        UserDefaults.standard.set(stepGoals, forKey: StorageKey.stepGoals)
        UserDefaults.standard.set(timeEarned, forKey: StorageKey.timeEarned)
        
        // 2. Save to App Group (for Shield and DeviceActivity Extensions)
        appGroupDefaults?.set(Int(stepGoals), forKey: StorageKey.stepGoals)
        appGroupDefaults?.set(timeEarned, forKey: StorageKey.timeEarned)
    }
    
    struct NoticeInfo {
        let title: String
        let message: String
    }
    
    func saveAndCheckNotice() -> NoticeInfo? {
        saveSettings()
        
        if isLocked && Int(stepGoals) != Int(initialStepGoals) {
            let currentTarget = activeStepTarget > 0 ? activeStepTarget : Int(initialStepGoals)
            return NoticeInfo(
                title: "Step Goal Updated",
                message: "Your active lock still requires \(currentTarget) steps. Your new goal of \(Int(stepGoals)) steps will take effect on your next lock cycle."
            )
        } else if !isLocked && timeEarned != initialTimeEarned {
            let currentAllowance = activeAllowanceMinutes > 0 ? activeAllowanceMinutes : initialTimeEarned
            return NoticeInfo(
                title: "Allowance Updated",
                message: "Your active allowance is still \(currentAllowance) minutes. Your new allowance of \(timeEarned) minutes will take effect on your next unlock."
            )
        }
        
        return nil
    }
}
