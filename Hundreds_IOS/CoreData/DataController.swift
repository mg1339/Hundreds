//
//  DataController.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HundredsModel")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                fatalError("Core Data error: \(error)")
            }
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        let context = container.viewContext
        context.delete(object)
        save()
    }
    
    // MARK: - Workout Day Operations
    
    func loadWorkoutDay(for date: Date) -> WorkoutDayEntity? {
        let context = container.viewContext
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        let request: NSFetchRequest<WorkoutDayEntity> = WorkoutDayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", startOfDay as NSDate)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch workout day: \(error)")
            return nil
        }
    }
    
    func saveWorkoutDay(_ workoutDay: WorkoutDay) {
        let context = container.viewContext
        
        // Try to find existing entity for this date
        if let existingEntity = loadWorkoutDay(for: workoutDay.date) {
            // Update existing entity
            existingEntity.pushups = workoutDay.pushups
            existingEntity.situps = workoutDay.situps
            existingEntity.squats = workoutDay.squats
            existingEntity.running = workoutDay.running
            existingEntity.lastModified = Date()
        } else {
            // Create new entity
            let entity = WorkoutDayEntity(context: context)
            entity.id = UUID()
            entity.date = Calendar.current.startOfDay(for: workoutDay.date)
            entity.pushups = workoutDay.pushups
            entity.situps = workoutDay.situps
            entity.squats = workoutDay.squats
            entity.running = workoutDay.running
            entity.lastModified = Date()
        }
        
        save()
    }
    
    func loadWorkoutHistory(from startDate: Date, to endDate: Date) -> [WorkoutDay] {
        let context = container.viewContext
        
        let request: NSFetchRequest<WorkoutDayEntity> = WorkoutDayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                      startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutDayEntity.date, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                WorkoutDay(
                    date: entity.date ?? Date(),
                    pushups: entity.pushups,
                    situps: entity.situps,
                    squats: entity.squats,
                    running: entity.running
                )
            }
        } catch {
            print("Failed to fetch workout history: \(error)")
            return []
        }
    }
    
    func loadAllWorkoutHistory() -> [WorkoutDay] {
        let context = container.viewContext
        
        let request: NSFetchRequest<WorkoutDayEntity> = WorkoutDayEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutDayEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                WorkoutDay(
                    date: entity.date ?? Date(),
                    pushups: entity.pushups,
                    situps: entity.situps,
                    squats: entity.squats,
                    running: entity.running
                )
            }
        } catch {
            print("Failed to fetch all workout history: \(error)")
            return []
        }
    }
}

// MARK: - Preview Support
extension DataController {
    static var preview: DataController = {
        let controller = DataController()
        let context = controller.container.viewContext
        
        // Add sample data for previews
        let sampleDates = [
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Date()
        ]
        
        let sampleWorkouts = [
            WorkoutDay(date: sampleDates[0], pushups: 100, situps: 100, squats: 100, running: 10.0),
            WorkoutDay(date: sampleDates[1], pushups: 50, situps: 75, squats: 60, running: 3.2),
            WorkoutDay(date: sampleDates[2], pushups: 25, situps: 30, squats: 40, running: 1.5)
        ]
        
        for workout in sampleWorkouts {
            controller.saveWorkoutDay(workout)
        }
        
        return controller
    }()
}