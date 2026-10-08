//
//  StepAvailability.swift
//  StepFirst
//

import Foundation
import CoreMotion

/// Whether this device can count steps for StepFirst right now.
/// Apps are only locked when steps can be counted, so the user can always walk to unlock.
enum StepAvailability: Equatable {
    case available
    /// The device has no step counter (e.g. most iPads).
    case unsupported
    /// Motion & Fitness access was denied or is restricted.
    case denied

    static var current: StepAvailability {
        #if DEBUG
        if let debugOverride { return debugOverride }
        #endif
        guard CMPedometer.isStepCountingAvailable() else { return .unsupported }
        switch CMPedometer.authorizationStatus() {
        case .denied, .restricted:
            return .denied
        default:
            return .available
        }
    }

    #if DEBUG
    /// Lets previews and tests show a specific state.
    nonisolated(unsafe) static var debugOverride: StepAvailability?
    #endif
}
