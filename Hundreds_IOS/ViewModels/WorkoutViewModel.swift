//
//  WorkoutViewModel.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import SwiftUI
import Combine
import UIKit

class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: WorkoutDay
    @Published var isLoading = false
    
    private var dataController: DataController?
    private var cancellables = Set<AnyCancellable>()
    private var dayCheckTimer: Timer?
    
    init() {
        self.currentWorkout = WorkoutDay.today
        setupDayCheckTimer()
    }
    
    func setDataController(_ dataController: DataController) {
        self.dataController = dataController
        loadTodaysWorkout()
    }
    
    // MARK: - Data Operations
    
    func loadTodaysWorkout() {
        guard let dataController = dataController else { return }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let entity = dataController.loadWorkoutDay(for: Date()) {
                let workout = WorkoutDay(
                    date: entity.date ?? Date(),
                    pushups: entity.pushups,
                    situps: entity.situps,
                    squats: entity.squats,
                    running: entity.running
                )
                
                DispatchQueue.main.async {
                    self.currentWorkout = workout
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.currentWorkout = WorkoutDay.today
                    self.isLoading = false
                }
            }
        }
    }
    
    private func saveCurrentWorkout() {
        guard let dataController = dataController else { return }
        
        DispatchQueue.global(qos: .utility).async {
            dataController.saveWorkoutDay(self.currentWorkout)
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
            self.checkForNewDay()
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