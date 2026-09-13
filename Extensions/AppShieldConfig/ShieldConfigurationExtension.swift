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

    private func getAppIcon() -> UIImage? {
        // 1. Direct file load from extension bundle
        if let path = Bundle(for: ShieldConfigurationExtension.self).path(forResource: "AppLogo", ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            return image.styledForShield()
        }
        
        // 2. Named asset load
        if let image = UIImage(named: "AppLogo", in: Bundle(for: ShieldConfigurationExtension.self), with: nil) {
            return image.styledForShield()
        }
        
        // 3. App Group shared container load
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupSuiteName) {
            let fileURL = groupURL.appendingPathComponent("AppLogo.png")
            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image.styledForShield()
            }
        }
        
        // 4. Fallback: High-contrast walking figure badge (visible on both light and dark backgrounds)
        return createFallbackIcon()
    }

    private func createFallbackIcon() -> UIImage? {
        let size = CGSize(width: 72, height: 72)
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)
            
            // Tinted circular container badge to guarantee contrast on ANY background mode
            let badgePath = UIBezierPath(ovalIn: rect)
            UIColor.systemIndigo.withAlphaComponent(0.16).setFill()
            badgePath.fill()
            
            // Walking figure in brand Indigo
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
            if let symbol = UIImage(systemName: "figure.walk.motion", withConfiguration: symbolConfig)?
                .withTintColor(.systemIndigo, renderingMode: .alwaysOriginal) {
                let symbolRect = CGRect(
                    x: (size.width - symbol.size.width) / 2,
                    y: (size.height - symbol.size.height) / 2,
                    width: symbol.size.width,
                    height: symbol.size.height
                )
                symbol.draw(in: symbolRect)
            }
        }.withRenderingMode(.alwaysOriginal)
    }

    private func createShieldConfiguration() -> ShieldConfiguration {
        let defaults = UserDefaults(suiteName: appGroupSuiteName)
        let activeTarget = defaults?.integer(forKey: "activeStepTarget") ?? 0
        let stepGoals = activeTarget > 0 ? activeTarget : (defaults?.integer(forKey: "stepGoals") ?? 200)
        let goalText = stepGoals > 0 ? "\(stepGoals)" : "your"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: getAppIcon(),
            title: ShieldConfiguration.Label(
                text: "\nLocked by StepFirst",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Walk \(goalText) steps to earn screen time.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Check Steps & Unlock",
                color: .white
            ),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Continue Walking",
                color: .label
            )
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

// MARK: - Shield Icon Styling
private extension UIImage {
    func styledForShield(targetSize: CGSize = CGSize(width: 72, height: 72)) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: targetSize)
            // Native Apple app icon squircle ratio (cornerRadius ~ 22.4%)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: targetSize.width * 0.224)
            path.addClip()
            self.draw(in: rect)
        }.withRenderingMode(.alwaysOriginal)
    }
}
