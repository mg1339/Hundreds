//
//  SettingsViewModel.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var useSliders: Bool {
        didSet {
            UserDefaults.standard.set(useSliders, forKey: "useSliders")
        }
    }
    
    @Published var showResetAlert = false
    @Published var showImportPicker = false
    @Published var showExportSuccess = false
    @Published var showImportSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showColorPicker = false
    @Published var selectedExerciseType: ExerciseType?
    
    // Workout colors
    @Published var pushupsColor: Color {
        didSet { saveColor(pushupsColor, for: "pushups") }
    }
    @Published var situpsColor: Color {
        didSet { saveColor(situpsColor, for: "situps") }
    }
    @Published var squatsColor: Color {
        didSet { saveColor(squatsColor, for: "squats") }
    }
    @Published var runningColor: Color {
        didSet { saveColor(runningColor, for: "running") }
    }
    
    private var modelContext: ModelContext?
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.useSliders = UserDefaults.standard.bool(forKey: "useSliders")
        
        // Load saved colors or use defaults (red blue red blue)
        self.pushupsColor = SettingsViewModel.loadColor(for: "pushups") ?? .red
        self.situpsColor = SettingsViewModel.loadColor(for: "situps") ?? .blue 
        self.squatsColor = SettingsViewModel.loadColor(for: "squats") ?? .red
        self.runningColor = SettingsViewModel.loadColor(for: "running") ?? .blue
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Dark Mode
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    // MARK: - Data Export
    
    func exportData() {
        guard let context = modelContext else {
            showErrorMessage("Unable to access data")
            return
        }
        
        do {
            let descriptor = FetchDescriptor<WorkoutDay>()
            let workouts = try context.fetch(descriptor)
            
            let exportData = workouts.map { workout in
                [
                    "date": workout.dateString,
                    "pushups": workout.pushups,
                    "situps": workout.situps,
                    "squats": workout.squats,
                    "running": workout.running
                ]
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            
            // Save to Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportURL = documentsPath.appendingPathComponent("hundreds_export_\(Date().timeIntervalSince1970).json")
            
            try jsonData.write(to: exportURL)
            
            // Share the file
            let activityVC = UIActivityViewController(activityItems: [exportURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
            
            showExportSuccess = true
            
        } catch {
            showErrorMessage("Failed to export data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Data Import
    
    func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importData(from: url)
        case .failure(let error):
            showErrorMessage("Failed to select file: \(error.localizedDescription)")
        }
    }
    
    private func importData(from url: URL) {
        guard let context = modelContext else {
            showErrorMessage("Unable to access data")
            return
        }
        
        do {
            guard url.startAccessingSecurityScopedResource() else {
                showErrorMessage("Unable to access selected file")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let jsonData = try Data(contentsOf: url)
            guard let importData = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                showErrorMessage("Invalid file format")
                return
            }
            
            for workoutData in importData {
                guard let dateString = workoutData["date"] as? String,
                      let pushups = workoutData["pushups"] as? Double,
                      let situps = workoutData["situps"] as? Double,
                      let squats = workoutData["squats"] as? Double,
                      let running = workoutData["running"] as? Double else {
                    continue
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let date = formatter.date(from: dateString) else { continue }
                
                // Check if workout already exists
                let startOfDay = Calendar.current.startOfDay(for: date)
                let descriptor = FetchDescriptor<WorkoutDay>(
                    predicate: #Predicate { $0.date == startOfDay }
                )
                
                let existingWorkouts = try context.fetch(descriptor)
                
                if let existingWorkout = existingWorkouts.first {
                    // Update existing workout
                    existingWorkout.pushups = pushups
                    existingWorkout.situps = situps
                    existingWorkout.squats = squats
                    existingWorkout.running = running
                } else {
                    // Create new workout
                    let workout = WorkoutDay(date: date, pushups: pushups, situps: situps, squats: squats, running: running)
                    context.insert(workout)
                }
            }
            
            try context.save()
            showImportSuccess = true
            
        } catch {
            showErrorMessage("Failed to import data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Reset Data
    
    func resetAllData() {
        guard let context = modelContext else {
            showErrorMessage("Unable to access data")
            return
        }
        
        do {
            let descriptor = FetchDescriptor<WorkoutDay>()
            let workouts = try context.fetch(descriptor)
            
            for workout in workouts {
                context.delete(workout)
            }
            
            try context.save()
            
        } catch {
            showErrorMessage("Failed to reset data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // MARK: - Color Management
    
    private func saveColor(_ color: Color, for exercise: String) {
        // Convert to a simple string representation
        let colorString: String
        switch color {
        case .red: colorString = "red"
        case .blue: colorString = "blue"
        case .green: colorString = "green"
        case .orange: colorString = "orange"
        case .yellow: colorString = "yellow"
        case .purple: colorString = "purple"
        case .pink: colorString = "pink"
        case .teal: colorString = "teal"
        case .cyan: colorString = "cyan"
        case .mint: colorString = "mint"
        case .indigo: colorString = "indigo"
        case .brown: colorString = "brown"
        case .gray: colorString = "gray"
        case .white: colorString = "white"
        case .black: colorString = "black"
        default: 
            // Handle dynamic colors
            if color == .primary {
                colorString = "label"
            } else {
                colorString = "red"
            }
        }
        UserDefaults.standard.set(colorString, forKey: "\(exercise)Color")
    }
    
    private static func loadColor(for exercise: String) -> Color? {
        guard let colorString = UserDefaults.standard.string(forKey: "\(exercise)Color") else { return nil }
        
        switch colorString {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        case "cyan": return .cyan
        case "mint": return .mint
        case "indigo": return .indigo
        case "brown": return .brown
        case "gray": return .gray
        case "label": return .primary
        case "white": return .white
        case "black": return .black
        default: return nil
        }
    }
    
    func getColor(for exerciseType: ExerciseType) -> Color {
        switch exerciseType.name {
        case "pushups":
            return pushupsColor
        case "situps":
            return situpsColor
        case "squats":
            return squatsColor
        case "running":
            return runningColor
        default:
            return .gray
        }
    }
    
    func setColor(_ color: Color, for exerciseType: ExerciseType) {
        switch exerciseType.name {
        case "pushups":
            pushupsColor = color
        case "situps":
            situpsColor = color
        case "squats":
            squatsColor = color
        case "running":
            runningColor = color
        default:
            break
        }
    }
}
