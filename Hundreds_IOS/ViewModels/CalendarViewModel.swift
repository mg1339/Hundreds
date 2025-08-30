//
//  CalendarViewModel.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import SwiftUI
import Combine

class CalendarViewModel: ObservableObject {
    @Published var currentMonth = Date()
    @Published var workoutHistory: [String: WorkoutDay] = [:]
    @Published var isLoading = false
    @Published var selectedDay: WorkoutDay?
    @Published var showingDayDetail = false
    
    private var dataController: DataController?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCurrentMonthData()
    }
    
    func setDataController(_ dataController: DataController) {
        self.dataController = dataController
        loadCurrentMonthData()
    }
    
    // MARK: - Data Loading
    
    func loadCurrentMonthData() {
        guard let dataController = dataController else { return }
        
        isLoading = true
        
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        DispatchQueue.global(qos: .userInitiated).async {
            let history = dataController.loadWorkoutHistory(from: startOfMonth, to: endOfMonth)
            
            DispatchQueue.main.async {
                self.workoutHistory = Dictionary(uniqueKeysWithValues: history.map { ($0.dateString, $0) })
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Calendar Navigation
    
    func navigateToPreviousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            loadCurrentMonthData()
        }
    }
    
    func navigateToNextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            loadCurrentMonthData()
        }
    }
    
    func navigateToToday() {
        currentMonth = Date()
        loadCurrentMonthData()
    }
    
    // MARK: - Calendar Data
    
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var calendarDays: [CalendarDay] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        // Get the first day of the week for the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.dateInterval(of: .month, for: currentMonth)?.duration ?? 0
        let numberOfDays = Int(daysInMonth / (24 * 60 * 60))
        
        var days: [CalendarDay] = []
        
        // Add empty days for the beginning of the month
        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: nil, workout: nil, isToday: false, isCurrentMonth: false))
        }
        
        // Add days of the month
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                let dateString = WorkoutDay(date: date).dateString
                let workout = workoutHistory[dateString]
                let isToday = calendar.isDate(date, inSameDayAs: Date())
                
                days.append(CalendarDay(
                    date: date,
                    workout: workout,
                    isToday: isToday,
                    isCurrentMonth: true
                ))
            }
        }
        
        return days
    }
    
    // MARK: - Day Selection
    
    func selectDay(_ calendarDay: CalendarDay) {
        guard let date = calendarDay.date else { return }
        
        if let workout = calendarDay.workout {
            selectedDay = workout
        } else {
            selectedDay = WorkoutDay(date: date)
        }
        
        showingDayDetail = true
    }
    
    func closeDayDetail() {
        showingDayDetail = false
        selectedDay = nil
    }
}

// MARK: - Calendar Day Model
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let workout: WorkoutDay?
    let isToday: Bool
    let isCurrentMonth: Bool
    
    var dayNumber: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var completionStatus: CompletionStatus {
        guard let workout = workout else { return .none }
        
        if workout.isComplete {
            return .complete
        } else if workout.hasProgress {
            return .partial
        } else {
            return .none
        }
    }
    
    var progressSummary: String {
        guard let workout = workout else { return "" }
        
        let pushups = Int(workout.pushups)
        let situps = Int(workout.situps)
        let squats = Int(workout.squats)
        let running = workout.running
        
        return "\(pushups)/\(situps)/\(squats)\n\(String(format: "%.1f", running))mi"
    }
}

enum CompletionStatus {
    case none
    case partial
    case complete
    
    var color: Color {
        switch self {
        case .none: return .gray.opacity(0.3)
        case .partial: return .orange
        case .complete: return .green
        }
    }
}