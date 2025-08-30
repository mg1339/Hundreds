//
//  WorkoutDayEntity+CoreDataProperties.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import CoreData

extension WorkoutDayEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDayEntity> {
        return NSFetchRequest<WorkoutDayEntity>(entityName: "WorkoutDayEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var pushups: Double
    @NSManaged public var situps: Double
    @NSManaged public var squats: Double
    @NSManaged public var running: Double
    @NSManaged public var lastModified: Date?

}

extension WorkoutDayEntity : Identifiable {

}