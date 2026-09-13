//
//  MockStepManager.swift
//  StepFirst
//
//  Created by Ferdynand Kee on 13/09/26.
//

import Foundation
internal import Combine

/// A fake StepTrackingService used for Unit Testing and Previews.
/// Allows simulating steps without needing physical iPhone motion hardware.
final class MockStepManager: StepTrackingService {
    @Published var liveSteps: Int = 0
    var isTracking: Bool = false
    var simulatedHistoricalSteps: Int = 0
    
    var liveStepsPublisher: AnyPublisher<Int, Never> {
        $liveSteps.eraseToAnyPublisher()
    }
    
    func startTracking() {
        isTracking = true
    }
    
    func stopTracking() {
        isTracking = false
    }
    
    func stepsToday(upTo date: Date) async -> Int {
        return simulatedHistoricalSteps
    }
    
    // MARK: - Test Helpers (Used in Unit Tests)
    
    /// Simulates walking a certain number of steps
    func simulateSteps(_ steps: Int) {
        self.liveSteps = steps
    }
}
