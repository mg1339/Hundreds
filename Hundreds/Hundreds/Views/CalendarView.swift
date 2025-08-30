//
//  CalendarView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
                
                // Calendar Header
                calendarHeader
                
                // Weekday Headers
                weekdayHeaders
                
                // Calendar Grid
                if calendarViewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    calendarGrid
                }
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                calendarViewModel.setModelContext(modelContext)
            }
            .refreshable {
                calendarViewModel.loadCurrentMonthData()
            }
            .sheet(isPresented: $calendarViewModel.showingDayDetail) {
                if let selectedDay = calendarViewModel.selectedDay {
                    DayDetailView(workoutDay: selectedDay)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var calendarHeader: some View {
        HStack {
            Button(action: {
                calendarViewModel.navigateToPreviousMonth()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(calendarViewModel.monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                calendarViewModel.navigateToNextMonth()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var weekdayHeaders: some View {
        HStack {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(calendarViewModel.calendarDays) { calendarDay in
                CalendarDayView(calendarDay: calendarDay, settingsViewModel: settingsViewModel) {
                    calendarViewModel.selectDay(calendarDay)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    

}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let calendarDay: CalendarDay
    let settingsViewModel: SettingsViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if calendarDay.isCurrentMonth {
                    ZStack {
                        // Ring background
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 36, height: 36)
                        
                        // Progressive exercise segments
                        if let workout = calendarDay.workout {
                            let segments = calculateProgressSegments(workout)
                            
                            // Pushups segment
                            if segments.pushupEnd > 0 {
                                Circle()
                                    .trim(from: 0, to: segments.pushupEnd)
                                    .stroke(exerciseColor(.pushups), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 36, height: 36)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.none, value: segments)
                            }
                            
                            // Situps segment
                            if segments.situpEnd > segments.situpStart {
                                Circle()
                                    .trim(from: segments.situpStart, to: segments.situpEnd)
                                    .stroke(exerciseColor(.situps), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 36, height: 36)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.none, value: segments)
                            }
                            
                            // Squats segment
                            if segments.squatEnd > segments.squatStart {
                                Circle()
                                    .trim(from: segments.squatStart, to: segments.squatEnd)
                                    .stroke(exerciseColor(.squats), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 36, height: 36)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.none, value: segments)
                            }
                            
                            // Running segment
                            if segments.runningEnd > segments.runningStart {
                                Circle()
                                    .trim(from: segments.runningStart, to: segments.runningEnd)
                                    .stroke(exerciseColor(.running), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 36, height: 36)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.none, value: segments)
                            }
                        }
                        
                        // Day number
                        Text(calendarDay.dayNumber)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textColor)
                    }
                } else {
                    // Empty space for days outside current month
                    Color.clear
                }
            }
            .frame(width: 54, height: 80)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: calendarDay.isToday ? 3 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!calendarDay.isCurrentMonth)
    }
    

    
    private var textColor: Color {
        if calendarDay.isToday {
            return .blue
        }
        return .primary
    }
    
    private var borderColor: Color {
        if calendarDay.isToday {
            return .blue
        }
        
        switch calendarDay.completionStatus {
        case .complete:
            return .green.opacity(0.6)
        case .partial:
            return .orange.opacity(0.6)
        case .none:
            return Color(.systemGray4)
        }
    }
    

    

    
    private func exerciseColor(_ exerciseType: ExerciseType) -> Color {
        return settingsViewModel.getColor(for: exerciseType)
    }
    
    private func calculateProgressSegments(_ workout: WorkoutDay) -> ProgressSegments {
        // Each exercise gets 25% of the ring (0.25)
        let pushupProgress = min(1.0, workout.pushups / 100.0) * 0.25
        let situpProgress = min(1.0, workout.situps / 100.0) * 0.25
        let squatProgress = min(1.0, workout.squats / 100.0) * 0.25
        let runningProgress = min(1.0, workout.running / 10.0) * 0.25
        
        return ProgressSegments(
            pushupEnd: pushupProgress,
            situpStart: pushupProgress,
            situpEnd: pushupProgress + situpProgress,
            squatStart: pushupProgress + situpProgress,
            squatEnd: pushupProgress + situpProgress + squatProgress,
            runningStart: pushupProgress + situpProgress + squatProgress,
            runningEnd: pushupProgress + situpProgress + squatProgress + runningProgress
        )
    }
}

struct ProgressSegments: Equatable {
    let pushupEnd: Double
    let situpStart: Double
    let situpEnd: Double
    let squatStart: Double
    let squatEnd: Double
    let runningStart: Double
    let runningEnd: Double
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
        .environmentObject(WorkoutViewModel())
        .environmentObject(SettingsViewModel())
        .modelContainer(for: WorkoutDay.self, inMemory: true)
}
