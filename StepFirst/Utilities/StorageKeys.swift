//
//  StorageKeys.swift
//  StepFirst
//

import Foundation

enum AppConfig {
    static let appGroupSuiteName = "group.com.kee.StepFirst"
}

enum StorageKey {
    // MARK: - App Group Shared Keys (Accessible by Extensions & Main App)
    static let stepGoals = "stepGoals"
    static let timeEarned = "timeEarned"
    static let isLocked = "isLocked"
    static let lockActivatedAt = "lockActivatedAt"
    static let activeStepTarget = "activeStepTarget"
    static let activeAllowanceMinutes = "activeAllowanceMinutes"
    static let usageToday = "selectedAppsUsageToday"
    static let savedAppTokens = "SavedAppTokens"
    
    // MARK: - Main App Private Keys (Used for UI & Dashboard tracking)
    static let secondsRemaining = "secondsRemaining"
    static let baselineSteps = "baselineSteps"
    static let initialUsage = "initialUsage"
    static let hasSetInitialUsage = "hasSetInitialUsage"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}
