//
//  ShieldConfigurationExtension.swift
//  AppShieldConfig
//
//  Created by Ferdynand Kee on 03/09/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private let appGroupSuiteName = "group.com.kee.StepFirst"

    private func createShieldConfiguration() -> ShieldConfiguration {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        let stepGoals = defaults?.integer(forKey: "stepGoals") ?? 200
        let goalText = stepGoals > 0 ? "\(stepGoals)" : "your"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "figure.walk.motion"),
            title: ShieldConfiguration.Label(text: "Apps Locked", color: .label),
            subtitle: ShieldConfiguration.Label(
                text: "Walk \(goalText) steps to unlock and earn your screen time.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Check Steps & Unlock", color: .white),
            primaryButtonBackgroundColor: UIColor.systemIndigo,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Okay", color: .secondaryLabel)
        )
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        createShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        createShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        createShieldConfiguration()
    }
}
