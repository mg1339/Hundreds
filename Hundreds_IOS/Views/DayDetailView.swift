//
//  DayDetailView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct DayDetailView: View {
    let workoutDay: WorkoutDay
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Header
                    dateHeader
                    
                    // Overall Progress
                    overallProgress
                    
                    // Exercise Details
                    exerciseDetails
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var dateHeader: some View {
        VStack(spacing: 8) {
            Text(workoutDay.displayDate)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if workoutDay.hasProgress {
                Text("Workout Completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("No Activity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var overallProgress: some View {
        VStack(spacing: 12) {
            Text("Total Completion")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: workoutDay.totalCompletionPercentage / 100)
                    .stroke(
                        workoutDay.isComplete ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(workoutDay.totalCompletionPercentage))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(workoutDay.isComplete ? .green : .primary)
                    
                    if workoutDay.isComplete {
                        Text("Complete!")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(workoutDay.isComplete ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(workoutDay.isComplete ? Color.green : Color.blue, lineWidth: 1)
        )
    }
    
    private var exerciseDetails: some View {
        VStack(spacing: 16) {
            Text("Exercise Breakdown")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(ExerciseType.allExercises, id: \.name) { exerciseType in
                    ExerciseDetailCard(
                        exerciseType: exerciseType,
                        workoutDay: workoutDay
                    )
                }
            }
        }
    }
}

// MARK: - Exercise Detail Card
struct ExerciseDetailCard: View {
    let exerciseType: ExerciseType
    let workoutDay: WorkoutDay
    
    var body: some View {
        VStack(spacing: 8) {
            Text(exerciseType.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(progressText)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(progressColor)
            
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(Int(completionPercentage))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progressColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var currentValue: Double {
        workoutDay.getValue(for: exerciseType)
    }
    
    private var progressText: String {
        let current = exerciseType.formatValue(currentValue)
        let target = exerciseType.formatTarget()
        return "\(current)/\(target)"
    }
    
    private var completionPercentage: Double {
        workoutDay.completionPercentage(for: exerciseType)
    }
    
    private var progressPercentage: Double {
        min(1.0, completionPercentage / 100.0)
    }
    
    private var progressColor: Color {
        if completionPercentage >= 100 {
            return .green
        } else if completionPercentage >= 50 {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    DayDetailView(
        workoutDay: WorkoutDay(
            date: Date(),
            pushups: 75,
            situps: 100,
            squats: 50,
            running: 3.2
        )
    )
}