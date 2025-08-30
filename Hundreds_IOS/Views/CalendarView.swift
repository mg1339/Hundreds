//
//  CalendarView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                
                // Back to Today Button
                backToTodayButton
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                calendarViewModel.setDataController(dataController)
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
        LazyVGrid(columns: columns, spacing: 1) {
            ForEach(calendarViewModel.calendarDays) { calendarDay in
                CalendarDayView(calendarDay: calendarDay) {
                    calendarViewModel.selectDay(calendarDay)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray5))
    }
    
    private var backToTodayButton: some View {
        Button(action: {
            calendarViewModel.navigateToToday()
        }) {
            Text("Back to Today")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let calendarDay: CalendarDay
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                if calendarDay.isCurrentMonth {
                    Text(calendarDay.dayNumber)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                    
                    if calendarDay.workout != nil {
                        Text(calendarDay.progressSummary)
                            .font(.system(size: 8))
                            .foregroundColor(textColor.opacity(0.8))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    // Empty space for days outside current month
                    Color.clear
                }
            }
            .frame(width: 45, height: 60)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: calendarDay.isToday ? 2 : 0)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!calendarDay.isCurrentMonth)
    }
    
    private var backgroundColor: Color {
        if !calendarDay.isCurrentMonth {
            return Color.clear
        }
        
        if calendarDay.isToday {
            return Color.blue.opacity(0.2)
        }
        
        switch calendarDay.completionStatus {
        case .complete:
            return Color.green.opacity(0.3)
        case .partial:
            return Color.orange.opacity(0.3)
        case .none:
            return Color(.systemBackground)
        }
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
        return .clear
    }
}

#Preview {
    CalendarView()
        .environmentObject(CalendarViewModel())
        .environmentObject(WorkoutViewModel())
        .environmentObject(DataController.preview)
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
}