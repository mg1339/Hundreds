//
//  ColorPickerView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI

struct ColorPickerView: View {
    let exerciseType: ExerciseType
    let currentColor: Color
    let onColorSelected: (Color) -> Void
    
    @State private var selectedColor: Color
    @State private var ringScale: CGFloat = 0.8
    
    private let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .teal,
        .cyan, .mint, .indigo, .brown, .gray, .white, .black, .primary
    ]
    
    init(exerciseType: ExerciseType, currentColor: Color, onColorSelected: @escaping (Color) -> Void) {
        self.exerciseType = exerciseType
        self.currentColor = currentColor
        self.onColorSelected = onColorSelected
        self._selectedColor = State(initialValue: currentColor)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 40)
                
                // Animated Color Ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 200, height: 200)
                    
                    // Selected color preview
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: ringScale)
                }
                
                // Color Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                    ForEach(availableColors, id: \.self) { color in
                        Button(action: {
                            selectColor(color)
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isSelected(color) ? Color.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .scaleEffect(isSelected(color) ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected(color))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .padding(.bottom, 40)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onColorSelected(currentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onColorSelected(selectedColor)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                ringScale = 1.0
            }
        }
    }
    

    
    private func selectColor(_ color: Color) {
        selectedColor = color
        
        // Trigger animations
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            ringScale = 1.2
        }
        
        // Return to normal scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                ringScale = 1.0
            }
        }
    }
    
    private func isSelected(_ color: Color) -> Bool {
        // Simple color comparison - in a real app you might want a more robust comparison
        return color == selectedColor
    }
}

#Preview {
    ColorPickerView(
        exerciseType: ExerciseType.pushups,
        currentColor: .red
    ) { _ in }
}
