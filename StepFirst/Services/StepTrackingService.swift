//
//  StepTrackingService.swift
//  StepFirst
//
//  Created by Ferdynand Kee on 13/09/26.
//

import Foundation
internal import Combine

protocol StepTrackingService: AnyObject {
    var liveSteps: Int { get }
    var liveStepsPublisher: AnyPublisher<Int, Never> { get }
    func startTracking()
    func stopTracking()
    func stepsToday(upTo date: Date) async -> Int
}
