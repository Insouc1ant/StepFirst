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
        // Load step goals
        let savedGoals = UserDefaults.standard.double(forKey: StorageKey.stepGoals)
        stepGoals = savedGoals > 0 ? savedGoals : 200
        
        // Load time earned
        let savedTime = UserDefaults.standard.integer(forKey: StorageKey.timeEarned)
        timeEarned = savedTime > 0 ? savedTime : 30
        
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
}
