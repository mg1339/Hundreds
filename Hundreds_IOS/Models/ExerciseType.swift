//
//  ExerciseType.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation

struct ExerciseType: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    let target: Double
    let increment: Double
    let maxValue: Double
    let decimalPlaces: Int
    let unit: String
    
    static let pushups = ExerciseType(
        name: "pushups",
        displayName: "Pushups",
        target: 100,
        increment: 1,
        maxValue: 999,
        decimalPlaces: 0,
        unit: ""
    )
    
    static let situps = ExerciseType(
        name: "situps",
        displayName: "Situps",
        target: 100,
        increment: 1,
        maxValue: 999,
        decimalPlaces: 0,
        unit: ""
    )
    
    static let squats = ExerciseType(
        name: "squats",
        displayName: "Squats",
        target: 100,
        increment: 1,
        maxValue: 999,
        decimalPlaces: 0,
        unit: ""
    )
    
    static let running = ExerciseType(
        name: "running",
        displayName: "Running",
        target: 10.0,
        increment: 0.1,
        maxValue: 99.9,
        decimalPlaces: 1,
        unit: "mi"
    )
    
    static let allExercises: [ExerciseType] = [.pushups, .situps, .squats, .running]
    
    func formatValue(_ value: Double) -> String {
        if decimalPlaces == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    func formatTarget() -> String {
        let targetString = formatValue(target)
        return unit.isEmpty ? targetString : "\(targetString) \(unit)"
    }
}