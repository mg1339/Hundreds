//
//  ExerciseCard.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI
import SwiftData

struct ExerciseCard: View {
    let exerciseType: ExerciseType
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedValue: Double = 0
    @State private var showingPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with title and progress
            header
            
            // Progress bar
            progressBar
            
            // Counter controls
            counterControls
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            selectedValue = workoutViewModel.currentWorkout.getValue(for: exerciseType)
        }
        .onChange(of: workoutViewModel.currentWorkout.getValue(for: exerciseType)) { oldValue, newValue in
            if !showingPicker {
                selectedValue = newValue
            }
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
                    .frame(height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(exerciseColor)
                    .frame(
                        width: geometry.size.width * min(1.0, workoutViewModel.progressPercentage(for: exerciseType)),
                        height: 8
                    )
                    .cornerRadius(4)
                    .animation(.easeInOut(duration: 0.5), value: workoutViewModel.progressPercentage(for: exerciseType))
            }
        }
        .frame(height: 8)
    }
    
    private var counterControls: some View {
        HStack {
            if settingsViewModel.useSliders {
                // Slider only - full width with proper spacing
                Spacer()
                    .frame(width: 44) // Match button width for alignment
                
                sliderView
                
                Spacer()
                    .frame(width: 44) // Match button width for alignment
            } else {
                // Decrement button - far left
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
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
                
                Spacer()
                
                // Picker button - center
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    selectedValue = workoutViewModel.currentWorkout.getValue(for: exerciseType)
                    showingPicker = true
                }) {
                    Text(exerciseType.formatValue(selectedValue))
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(minWidth: 60, minHeight: 44)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .sheet(isPresented: $showingPicker) {
                    pickerView
                        .presentationDetents([.height(252)])
                        .onAppear {
                            selectedValue = workoutViewModel.currentWorkout.getValue(for: exerciseType)
                        }
                }
                
                Spacer()
                
                // Increment button - far right
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
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
    }
    
    // MARK: - Slider View
    
    private var sliderView: some View {
        VStack(spacing: 8) {
            Text(exerciseType.formatValue(selectedValue))
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Slider(
                value: $selectedValue,
                in: 0...exerciseType.maxValue,
                step: exerciseType.decimalPlaces > 0 ? 0.1 : 1.0
            ) { editing in
                if !editing {
                    // Haptic feedback when done sliding
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    workoutViewModel.updateExercise(exerciseType, value: selectedValue)
                }
            }
            .accentColor(exerciseColor)
            .frame(minWidth: 60)
        }
    }
    
    // MARK: - Picker View
    
    private var pickerView: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Select \(exerciseType.displayName)")
                    .font(.headline)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                Picker("Value", selection: $selectedValue) {
                    ForEach(pickerValues, id: \.self) { value in
                        Text(exerciseType.formatValue(value))
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 108)
                .clipped()
                
                Spacer(minLength: 12)
            }
            .navigationTitle(exerciseType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingPicker = false
                        selectedValue = workoutViewModel.currentWorkout.getValue(for: exerciseType)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        workoutViewModel.updateExercise(exerciseType, value: selectedValue)
                        showingPicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var pickerValues: [Double] {
        let step = exerciseType.decimalPlaces > 0 ? 0.1 : 1.0
        let maxValue = exerciseType.maxValue
        var values: [Double] = []
        
        var currentValue = 0.0
        while currentValue <= maxValue {
            // Round to avoid floating point precision issues
            let roundedValue = exerciseType.decimalPlaces > 0 
                ? round(currentValue * 10) / 10 
                : round(currentValue)
            values.append(roundedValue)
            currentValue += step
        }
        
        return values
    }
    
    private var borderColor: Color {
        let percentage = workoutViewModel.progressPercentage(for: exerciseType)
        if percentage >= 1.0 {
            return .green
        } else {
            return .blue
        }
    }
    
    private var exerciseColor: Color {
        return settingsViewModel.getColor(for: exerciseType)
    }
    

}

#Preview {
    VStack(spacing: 20) {
        ExerciseCard(exerciseType: ExerciseType.pushups)
        ExerciseCard(exerciseType: ExerciseType.running)
    }
    .padding()
    .environmentObject(WorkoutViewModel())
    .environmentObject(SettingsViewModel())
}
