# Core Data Model: HundredsModel.xcdatamodeld

This file documents the Core Data model structure that needs to be created in Xcode.

## Entity: WorkoutDayEntity

### Attributes:
- **id**: UUID, Optional: NO, Default: UUID()
- **date**: Date, Optional: NO, Used for: Primary date identifier (start of day)
- **pushups**: Double, Optional: NO, Default: 0, Min: 0, Max: 999
- **situps**: Double, Optional: NO, Default: 0, Min: 0, Max: 999
- **squats**: Double, Optional: NO, Default: 0, Min: 0, Max: 999
- **running**: Double, Optional: NO, Default: 0, Min: 0, Max: 99.9
- **lastModified**: Date, Optional: YES, Used for: Tracking when record was last updated

### Indexes:
- **date**: Used for efficient date-based queries

### Codegen:
- **Category/Extension**: Manual/None (we provide our own extensions)

## Instructions for Xcode Setup:

1. In Xcode, create a new Core Data model file named "HundredsModel.xcdatamodeld"
2. Add the WorkoutDayEntity entity with the attributes listed above
3. Set the Codegen to "Manual/None" 
4. The WorkoutDayEntity+CoreDataClass.swift and WorkoutDayEntity+CoreDataProperties.swift files are already provided
5. Build the project to generate the Core Data stack

## Alternative: Using @Model (iOS 17+)

If targeting iOS 17+, consider using SwiftData instead of Core Data for a more modern approach.