//
//  SettingsView.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    // Appearance Section
                    Section("Appearance") {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text("Dark Mode")
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: $settingsViewModel.isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .onChange(of: settingsViewModel.isDarkMode) { _, _ in
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                        }
                        .padding(.vertical, 2)
                        
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text("Use Sliders")
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: $settingsViewModel.useSliders)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .onChange(of: settingsViewModel.useSliders) { _, _ in
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                        }
                        .padding(.vertical, 2)
                    }
                    
                    // Workout Colors Section
                    Section("Workout Colors") {
                        ForEach(ExerciseType.allExercises, id: \.name) { exerciseType in
                            HStack {
                                Text(exerciseType.displayName)
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    settingsViewModel.selectedExerciseType = exerciseType
                                    settingsViewModel.showColorPicker = true
                                }) {
                                    Circle()
                                        .fill(settingsViewModel.getColor(for: exerciseType))
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Data Section
                    Section("Data") {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                                .foregroundColor(.green)
                                .frame(width: 24, height: 24)
                            
                            Text("Export Data")
                                .font(.body)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 2)
                        .onTapGesture {
                            settingsViewModel.exportData()
                        }
                        
                        HStack {
                            Image(systemName: "arrow.down.doc")
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                            
                            Text("Import Data")
                                .font(.body)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 2)
                        .onTapGesture {
                            settingsViewModel.showImportPicker = true
                        }
                    }
                    
                    // Reset Section
                    Section("Reset") {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                            
                            Text("Reset All Data")
                                .font(.body)
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 2)
                        .onTapGesture {
                            settingsViewModel.showResetAlert = true
                        }
                    }
                    
                    // About Section
                    Section("About") {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hundreds")
                                    .font(.body)
                                Text("Version 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                settingsViewModel.setModelContext(modelContext)
            }
            .alert("Reset All Data", isPresented: $settingsViewModel.showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    settingsViewModel.resetAllData()
                }
            } message: {
                Text("This will permanently delete all your workout data. This action cannot be undone.")
            }
            .fileImporter(
                isPresented: $settingsViewModel.showImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                settingsViewModel.handleImport(result: result)
            }
            .alert("Export Complete", isPresented: $settingsViewModel.showExportSuccess) {
                Button("OK") { }
            } message: {
                Text("Your workout data has been exported successfully.")
            }
            .alert("Import Complete", isPresented: $settingsViewModel.showImportSuccess) {
                Button("OK") { }
            } message: {
                Text("Your workout data has been imported successfully.")
            }
            .alert("Error", isPresented: $settingsViewModel.showError) {
                Button("OK") { }
            } message: {
                Text(settingsViewModel.errorMessage)
            }
            .sheet(isPresented: $settingsViewModel.showColorPicker) {
                if let exerciseType = settingsViewModel.selectedExerciseType {
                    ColorPickerView(
                        exerciseType: exerciseType,
                        currentColor: settingsViewModel.getColor(for: exerciseType)
                    ) { color in
                        settingsViewModel.setColor(color, for: exerciseType)
                        settingsViewModel.showColorPicker = false
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }
    

}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .modelContainer(for: WorkoutDay.self, inMemory: true)
}
