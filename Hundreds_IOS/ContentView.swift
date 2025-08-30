//
//  ContentView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem {
                    Label("Today", systemImage: "figure.strengthtraining.traditional")
                }
                .environmentObject(workoutViewModel)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .environmentObject(calendarViewModel)
                .environmentObject(workoutViewModel)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
}