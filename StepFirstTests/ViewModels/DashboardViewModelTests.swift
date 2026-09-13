//
//  StepFirstTests.swift
//  StepFirstTests
//
//  Created by Ferdynand Kee on 13/09/26.
//

import Testing
@testable import StepFirst

@Suite("Dashboard ViewModel Tests")
@MainActor
struct DashboardViewModelTests {
    let mock = MockStepManager()
    let sut: DashboardViewModel
    
    init() {
        sut = DashboardViewModel(stepManager: mock)
    }
    
    @Test("Calculates current steps as difference from baseline")
    func currentStepsCalculation() {
        // GIVEN: Baseline is 1000 steps from this morning
        sut.baselineSteps = 1000
        
        // WHEN: User walks and current total steps is 1050
        mock.simulateSteps(1050)
        
        // THEN: Current steps in this cycle must be exactly 50
        #expect(sut.currentSteps == 50)
    }
    
    @Test("Steps should never return a negative number")
    func currentStepsNeverNegative() {
        // GIVEN: Baseline is 500, but live steps is somehow 400
        sut.baselineSteps = 500
        mock.simulateSteps(400)
        
        // THEN: Must be clamped to 0
        #expect(sut.currentSteps == 0)
    }
    
    @Test("Unlocks automatically when step goal is reached")
    func unlocksWhenGoalReached() {
        // GIVEN: Target is 200 steps and the app is currently locked
        sut.stepGoals = 200
        sut.baselineSteps = 0
        sut.lockStatus = true
        
        // WHEN: Pedometer reports 200 steps
        mock.simulateSteps(200)
        
        // THEN: The app should automatically unlock!
        #expect(sut.lockStatus == false)
    }
    
    @Test("Remains locked when steps are below goal")
    func remainsLockedBelowGoal() {
        // GIVEN: Target is 200 steps and the app is currently locked
        sut.stepGoals = 200
        sut.baselineSteps = 0
        sut.lockStatus = true
        
        // WHEN: Pedometer only reports 150 steps (50 steps short)
        mock.simulateSteps(150)
        
        // THEN: The app must remain locked
        #expect(sut.lockStatus == true)
    }
}
