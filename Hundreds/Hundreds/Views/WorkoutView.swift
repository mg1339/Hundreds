//
//  WorkoutView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
                            VStack(spacing: 20) {
                    // Main Title
                    mainTitle
                    
                    // Exercise Cards
                    exerciseList
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                // Dismiss keyboard when tapping outside text fields
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        showResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Reset Today's Workout", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    workoutViewModel.resetTodaysWorkout()
                }
            } message: {
                Text("Are you sure you want to reset today's progress? This cannot be undone.")
            }
            .onAppear {
                workoutViewModel.setModelContext(modelContext)
            }
            .refreshable {
                workoutViewModel.loadTodaysWorkout()
            }
        }
    }
    
    @State private var showResetAlert = false
    
    // MARK: - View Components
    
    private var mainTitle: some View {
        VStack(spacing: 8) {
            Text("HUNDREDS")
                .font(.system(size: 48, weight: .black, design: .default))
                .kerning(2.0)
                .foregroundColor(.primary)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Rectangle()
                .fill(Color.red)
                .frame(width: 60, height: 3)
                .cornerRadius(1.5)
            
            if workoutViewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.top, 10)
    }
    

    
    private var exerciseList: some View {
        VStack(spacing: 12) {
            ForEach(ExerciseType.allExercises, id: \.name) { exerciseType in
                ExerciseCard(exerciseType: exerciseType)
                    .environmentObject(workoutViewModel)
                    .environmentObject(settingsViewModel)
            }
        }
    }
    

}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutViewModel())
        .environmentObject(SettingsViewModel())
        .modelContainer(for: WorkoutDay.self, inMemory: true)
}
