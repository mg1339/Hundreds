//
//  ContentView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem {
                    Label("Today", systemImage: "figure.run")
                }
                .environmentObject(workoutViewModel)
                .environmentObject(settingsViewModel)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .environmentObject(calendarViewModel)
                .environmentObject(workoutViewModel)
                .environmentObject(settingsViewModel)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .environmentObject(settingsViewModel)
        }
        .accentColor(.blue)
        .preferredColorScheme(settingsViewModel.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutDay.self, inMemory: true)
}
