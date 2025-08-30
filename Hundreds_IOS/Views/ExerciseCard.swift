//
//  ExerciseCard.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct ExerciseCard: View {
    let exerciseType: ExerciseType
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with title and progress
            header
            
            // Progress bar
            progressBar
            
            // Counter controls
            counterControls
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(progressColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            updateInputText()
        }
        .onChange(of: workoutViewModel.currentWorkout) { _ in
            updateInputText()
        }
    }
    
    // MARK: - View Components
    
    private var header: some View {
        VStack(spacing: 4) {
            Text(exerciseType.displayName)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(workoutViewModel.formattedProgress(for: exerciseType))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(progressColor)
                    .frame(
                        width: geometry.size.width * min(1.0, workoutViewModel.progressPercentage(for: exerciseType)),
                        height: 6
                    )
                    .cornerRadius(3)
                    .animation(.easeInOut(duration: 0.3), value: workoutViewModel.progressPercentage(for: exerciseType))
            }
        }
        .frame(height: 6)
    }
    
    private var counterControls: some View {
        HStack(spacing: 12) {
            // Decrement button
            Button(action: {
                workoutViewModel.decrementExercise(exerciseType)
            }) {
                Image(systemName: "minus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.red)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Input field
            TextField("0", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(exerciseType.decimalPlaces > 0 ? .decimalPad : .numberPad)
                .multilineTextAlignment(.center)
                .font(.title3)
                .fontWeight(.medium)
                .focused($isInputFocused)
                .onSubmit {
                    submitInput()
                }
                .onChange(of: inputText) { newValue in
                    if isEditing {
                        validateAndUpdateInput(newValue)
                    }
                }
                .onTapGesture {
                    isEditing = true
                    isInputFocused = true
                }
                .frame(minWidth: 60)
            
            // Increment button
            Button(action: {
                workoutViewModel.incrementExercise(exerciseType)
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Computed Properties
    
    private var progressColor: Color {
        let percentage = workoutViewModel.progressPercentage(for: exerciseType)
        if percentage >= 1.0 {
            return .green
        } else if percentage >= 0.5 {
            return .orange
        } else {
            return .blue
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateInputText() {
        if !isEditing {
            let value = workoutViewModel.currentWorkout.getValue(for: exerciseType)
            inputText = exerciseType.formatValue(value)
        }
    }
    
    private func validateAndUpdateInput(_ newValue: String) {
        // Allow empty string while editing
        if newValue.isEmpty {
            return
        }
        
        // Validate numeric input
        let filtered = newValue.filter { character in
            if exerciseType.decimalPlaces > 0 {
                return character.isNumber || character == "."
            } else {
                return character.isNumber
            }
        }
        
        if filtered != newValue {
            inputText = filtered
        }
    }
    
    private func submitInput() {
        isEditing = false
        isInputFocused = false
        
        guard let value = Double(inputText) else {
            updateInputText() // Reset to current value if invalid
            return
        }
        
        workoutViewModel.updateExercise(exerciseType, value: value)
        updateInputText() // Update with validated/formatted value
    }
}

#Preview {
    VStack(spacing: 20) {
        ExerciseCard(exerciseType: .pushups)
        ExerciseCard(exerciseType: .running)
    }
    .padding()
    .environmentObject(WorkoutViewModel())
}