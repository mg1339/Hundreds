//
//  WorkoutDay.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation

struct WorkoutDay: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var pushups: Double
    var situps: Double
    var squats: Double
    var running: Double
    
    init(date: Date = Date(), pushups: Double = 0, situps: Double = 0, squats: Double = 0, running: Double = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.pushups = pushups
        self.situps = situps
        self.squats = squats
        self.running = running
    }
    
    // Get exercise value by type
    func getValue(for exerciseType: ExerciseType) -> Double {
        switch exerciseType.name {
        case "pushups": return pushups
        case "situps": return situps
        case "squats": return squats
        case "running": return running
        default: return 0
        }
    }
    
    // Set exercise value by type
    mutating func setValue(_ value: Double, for exerciseType: ExerciseType) {
        let clampedValue = max(0, min(exerciseType.maxValue, value))
        
        switch exerciseType.name {
        case "pushups": pushups = clampedValue
        case "situps": situps = clampedValue
        case "squats": squats = clampedValue
        case "running": running = (clampedValue * 10).rounded() / 10 // Round to 1 decimal
        default: break
        }
    }
    
    // Calculate completion percentage for a specific exercise
    func completionPercentage(for exerciseType: ExerciseType) -> Double {
        let value = getValue(for: exerciseType)
        return min(100, (value / exerciseType.target) * 100)
    }
    
    // Calculate overall completion percentage
    var totalCompletionPercentage: Double {
        let percentages = ExerciseType.allExercises.map { completionPercentage(for: $0) }
        return percentages.reduce(0, +) / Double(percentages.count)
    }
    
    // Check if workout is complete
    var isComplete: Bool {
        return totalCompletionPercentage >= 100
    }
    
    // Check if there's any progress
    var hasProgress: Bool {
        return pushups > 0 || situps > 0 || squats > 0 || running > 0
    }
    
    // Get formatted date string
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Get display date string
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

// MARK: - Static helpers
extension WorkoutDay {
    static var today: WorkoutDay {
        WorkoutDay(date: Date())
    }
    
    static func forDate(_ date: Date) -> WorkoutDay {
        WorkoutDay(date: date)
    }
}