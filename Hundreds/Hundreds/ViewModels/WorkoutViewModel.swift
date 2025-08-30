//
//  WorkoutViewModel.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import UIKit

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: WorkoutDay
    @Published var isLoading = false
    
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    private var dayCheckTimer: Timer?
    
    init() {
        self.currentWorkout = WorkoutDay.today
        setupDayCheckTimer()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadTodaysWorkout()
    }
    
    // MARK: - Data Operations
    
    func loadTodaysWorkout() {
        guard let context = modelContext else { return }
        
        isLoading = true
        
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<WorkoutDay>(
            predicate: #Predicate { $0.date == today }
        )
        
        do {
            let workouts = try context.fetch(descriptor)
            if let workout = workouts.first {
                currentWorkout = workout
            } else {
                currentWorkout = WorkoutDay.today
            }
        } catch {
            print("Failed to load today's workout: \(error)")
            currentWorkout = WorkoutDay.today
        }
        
        isLoading = false
    }
    
    private func saveCurrentWorkout() {
        guard let context = modelContext else { return }
        
        do {
            // Check if this workout already exists in the context
            let today = Calendar.current.startOfDay(for: Date())
            let descriptor = FetchDescriptor<WorkoutDay>(
                predicate: #Predicate { $0.date == today }
            )
            
            let existingWorkouts = try context.fetch(descriptor)
            
            if let existingWorkout = existingWorkouts.first {
                // Update existing workout
                existingWorkout.pushups = currentWorkout.pushups
                existingWorkout.situps = currentWorkout.situps
                existingWorkout.squats = currentWorkout.squats
                existingWorkout.running = currentWorkout.running
            } else {
                // Insert new workout
                context.insert(currentWorkout)
            }
            
            try context.save()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
    
    // MARK: - Exercise Updates
    
    func updateExercise(_ exerciseType: ExerciseType, value: Double) {
        currentWorkout.setValue(value, for: exerciseType)
        saveCurrentWorkout()
        
        // Add haptic feedback for milestone achievements
        if currentWorkout.completionPercentage(for: exerciseType) >= 100 {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    func incrementExercise(_ exerciseType: ExerciseType) {
        let currentValue = currentWorkout.getValue(for: exerciseType)
        let newValue = currentValue + exerciseType.increment
        updateExercise(exerciseType, value: newValue)
    }
    
    func decrementExercise(_ exerciseType: ExerciseType) {
        let currentValue = currentWorkout.getValue(for: exerciseType)
        let newValue = max(0, currentValue - exerciseType.increment)
        updateExercise(exerciseType, value: newValue)
    }
    
    // MARK: - Computed Properties
    
    var totalProgress: Double {
        currentWorkout.totalCompletionPercentage
    }
    
    var isWorkoutComplete: Bool {
        currentWorkout.isComplete
    }
    
    var motivationalMessage: String {
        let progress = totalProgress
        
        switch progress {
        case 0:
            return "Ready to crush your hundreds? 💪"
        case 0..<25:
            return "Great start! Keep it up! 🚀"
        case 25..<50:
            return "You're making progress! 🔥"
        case 50..<75:
            return "Halfway there! Don't stop now! ⚡"
        case 75..<100:
            return "Almost there! Push through! 🎯"
        case 100...:
            return "Hundreds complete! You're amazing! 🏆"
        default:
            return "Keep going! 💪"
        }
    }
    
    // MARK: - Day Transition Handling
    
    private func setupDayCheckTimer() {
        // Check for day change every minute
        dayCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in
                self.checkForNewDay()
            }
        }
    }
    
    private func checkForNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let currentWorkoutDate = Calendar.current.startOfDay(for: currentWorkout.date)
        
        if today != currentWorkoutDate {
            handleNewDay()
        }
    }
    
    private func handleNewDay() {
        // Save current workout if it has progress
        if currentWorkout.hasProgress {
            saveCurrentWorkout()
        }
        
        // Reset to new day
        currentWorkout = WorkoutDay.today
        
        // Show notification
        DispatchQueue.main.async {
            // You could show a toast notification here
            print("New day started! 💪")
        }
    }
    
    // MARK: - Reset Functions
    
    func resetTodaysWorkout() {
        currentWorkout = WorkoutDay.today
        saveCurrentWorkout()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Cleanup
    
    deinit {
        dayCheckTimer?.invalidate()
        cancellables.removeAll()
    }
}

// MARK: - Formatting Helpers
extension WorkoutViewModel {
    func formattedValue(for exerciseType: ExerciseType) -> String {
        let value = currentWorkout.getValue(for: exerciseType)
        return exerciseType.formatValue(value)
    }
    
    func formattedProgress(for exerciseType: ExerciseType) -> String {
        let current = formattedValue(for: exerciseType)
        let target = exerciseType.formatTarget()
        return "\(current)/\(target)"
    }
    
    func progressPercentage(for exerciseType: ExerciseType) -> Double {
        return currentWorkout.completionPercentage(for: exerciseType) / 100.0
    }
}
