//
//  WorkoutView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Display
                    dateHeader
                    
                    // Progress Summary
                    progressSummary
                    
                    // Exercise Cards
                    exerciseGrid
                    
                    // Motivational Message
                    motivationalMessage
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Hundreds")
            .navigationBarTitleDisplayMode(.large)
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
                workoutViewModel.setDataController(dataController)
            }
            .refreshable {
                workoutViewModel.loadTodaysWorkout()
            }
        }
    }
    
    @State private var showResetAlert = false
    
    // MARK: - View Components
    
    private var dateHeader: some View {
        VStack(spacing: 4) {
            Text(workoutViewModel.currentWorkout.displayDate)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if workoutViewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.top)
    }
    
    private var progressSummary: some View {
        VStack(spacing: 8) {
            Text("Total Progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: workoutViewModel.totalProgress / 100)
                    .stroke(
                        workoutViewModel.isWorkoutComplete ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: workoutViewModel.totalProgress)
                
                Text("\(Int(workoutViewModel.totalProgress))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(workoutViewModel.isWorkoutComplete ? .green : .primary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var exerciseGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(ExerciseType.allExercises, id: \.name) { exerciseType in
                ExerciseCard(exerciseType: exerciseType)
                    .environmentObject(workoutViewModel)
            }
        }
    }
    
    private var motivationalMessage: some View {
        Text(workoutViewModel.motivationalMessage)
            .font(.title3)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(workoutViewModel.isWorkoutComplete ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(workoutViewModel.isWorkoutComplete ? Color.green : Color.blue, lineWidth: 1)
            )
    }
}

#Preview {
    WorkoutView()
        .environmentObject(WorkoutViewModel())
        .environmentObject(DataController.preview)
        .environment(\.managedObjectContext, DataController.preview.container.viewContext)
}