# Hundreds iOS App - Conversion Plan

## Overview
This document outlines the plan to convert the "Hundreds" workout tracking PWA into a native iOS app using SwiftUI. The focus is on core functionality first: daily tracking, basic calendar, and simple data persistence.

## Current Web App Analysis

### Core Features to Convert
- **Daily Exercise Tracking**: 4 exercises (pushups, situps, squats, running)
- **Counter Interface**: +/- buttons and direct input fields
- **Progress Visualization**: Current count vs target (100/100/100/10.0)
- **Calendar View**: Monthly grid showing workout history
- **Data Persistence**: Local storage with automatic day transitions
- **Date Management**: Automatic midnight reset and date formatting

### Current Data Structure
```javascript
{
  currentDate: "2025-01-15",
  currentData: {
    pushups: 25,
    situps: 50, 
    squats: 30,
    running: 1.5
  },
  workoutHistory: {
    "2025-01-14": {
      pushups: 100,
      situps: 100,
      squats: 100,
      running: 5.0,
      timestamp: "2025-01-14T23:45:00.000Z"
    }
  }
}
```

## iOS App Architecture

### Technology Stack
- **Framework**: SwiftUI (iOS 15+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Core Data
- **Navigation**: NavigationStack (iOS 16+) with TabView
- **Date Handling**: Foundation Date and Calendar APIs

### App Structure
```
HundredsApp/
├── Models/
│   ├── Exercise.swift           # Exercise data model
│   ├── WorkoutDay.swift         # Daily workout data
│   └── WorkoutHistory.swift     # Historical data management
├── ViewModels/
│   ├── WorkoutViewModel.swift   # Main workout logic
│   └── CalendarViewModel.swift  # Calendar data management
├── Views/
│   ├── ContentView.swift        # Main tab container
│   ├── WorkoutView.swift        # Daily tracking interface
│   ├── ExerciseCard.swift       # Individual exercise counter
│   ├── CalendarView.swift       # Monthly calendar grid
│   └── DayDetailView.swift      # Individual day details
├── Core Data/
│   ├── DataController.swift     # Core Data stack
│   └── HundredsModel.xcdatamodeld
└── Utilities/
    ├── DateExtensions.swift     # Date formatting helpers
    └── Constants.swift          # App constants
```

## Detailed Implementation Plan

### Phase 1: Project Setup and Data Models

#### 1.1 Xcode Project Creation
- Create new iOS app project "Hundreds"
- Configure deployment target: iOS 15.0+
- Add Core Data capability
- Set up basic app configuration (Bundle ID, version, etc.)

#### 1.2 Core Data Model Design
```swift
// Exercise Entity
- id: UUID
- name: String (pushups, situps, squats, running)
- currentCount: Double
- targetCount: Double
- date: Date

// WorkoutDay Entity  
- id: UUID
- date: Date
- pushups: Double
- situps: Double
- squats: Double
- running: Double
- isComplete: Bool
- completionPercentage: Double
```

#### 1.3 Swift Data Models
```swift
struct ExerciseType {
    let name: String
    let target: Double
    let increment: Double
    let displayFormat: String
}

class WorkoutData: ObservableObject {
    @Published var currentDay: WorkoutDay
    @Published var history: [WorkoutDay]
}
```

### Phase 2: Core Workout Tracking

#### 2.1 Main Workout View
- TabView with "Today" and "Calendar" tabs
- Current date display
- Grid of 4 exercise cards
- Real-time progress updates

#### 2.2 Exercise Counter Component
```swift
struct ExerciseCard: View {
    @Binding var count: Double
    let exercise: ExerciseType
    
    // Counter buttons (+/-)
    // Direct input field
    // Progress indicator
    // Target display (e.g., "25/100")
}
```

#### 2.3 Counter Logic
- Increment/decrement with proper bounds checking
- Input validation (0-999 for exercises, 0-99.9 for running)
- Decimal precision for running (0.1 increments)
- Automatic save on changes

### Phase 3: Data Persistence

#### 3.1 Core Data Stack
```swift
class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    func save()
    func loadTodaysWorkout() -> WorkoutDay
    func saveWorkout(_ workout: WorkoutDay)
    func loadHistory() -> [WorkoutDay]
}
```

#### 3.2 Automatic Day Transitions
- Background task to check for date changes
- Automatic save of previous day's data
- Reset current counters at midnight
- Preserve workout history

### Phase 4: Calendar View

#### 4.1 Monthly Calendar Grid
- 7x6 grid layout using LazyVGrid
- Month navigation (previous/next buttons)
- Color-coded days:
  - Green: Complete (100% of all exercises)
  - Yellow: Partial progress
  - Gray: No activity

#### 4.2 Day Detail View
- Sheet presentation for selected days
- Display all exercise counts
- Show completion percentage
- Historical data from Core Data

### Phase 5: Navigation and Polish

#### 5.1 App Navigation
```swift
struct ContentView: View {
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem { Label("Today", systemImage: "figure.strengthtraining.traditional") }
            
            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }
}
```

#### 5.2 iOS Design Patterns
- Native iOS styling with system colors
- Proper accessibility labels
- Haptic feedback for button interactions
- Pull-to-refresh on calendar view
- Swipe gestures where appropriate

## Key Technical Decisions

### Data Persistence Strategy
**Choice**: Core Data over UserDefaults
**Reasoning**: 
- Better performance for historical data queries
- Relationship management between entities
- Built-in data migration support
- Scalable for future features

### Architecture Pattern
**Choice**: MVVM with ObservableObject
**Reasoning**:
- Natural fit with SwiftUI's reactive paradigm
- Clear separation of concerns
- Testable business logic
- Follows iOS development best practices

### Navigation Approach
**Choice**: TabView for main navigation
**Reasoning**:
- Matches the web app's dual-view structure
- Familiar iOS pattern for users
- Easy access to both primary functions

## Development Timeline

### Week 1: Foundation
- [ ] Set up Xcode project and Core Data model
- [ ] Create basic data models and view models
- [ ] Implement Core Data stack

### Week 2: Core Functionality  
- [ ] Build main workout tracking interface
- [ ] Implement exercise counters with validation
- [ ] Add data persistence and retrieval

### Week 3: Calendar and Polish
- [ ] Create calendar view with monthly navigation
- [ ] Add day detail views
- [ ] Implement automatic day transitions

### Week 4: Testing and Refinement
- [ ] Test all core functionality
- [ ] Add proper error handling
- [ ] Polish UI and add iOS-specific touches

## Success Criteria

### Core Functionality
- ✅ Track daily progress for all 4 exercises
- ✅ Persist data locally with Core Data
- ✅ Display monthly calendar with workout history
- ✅ Automatic day transitions at midnight
- ✅ Input validation and error handling

### User Experience
- ✅ Intuitive counter interface matching web app
- ✅ Native iOS look and feel
- ✅ Smooth navigation between views
- ✅ Proper accessibility support
- ✅ Responsive performance

### Technical Quality
- ✅ Clean MVVM architecture
- ✅ Proper error handling
- ✅ Memory management
- ✅ Code documentation
- ✅ Unit tests for core logic

## Future Enhancement Opportunities

### Phase 2 Features (Post-MVP)
- **Themes**: Multiple color schemes like web app
- **Data Export/Import**: JSON backup functionality  
- **Widgets**: Home screen widgets for quick progress view
- **Shortcuts**: Siri shortcuts for logging workouts
- **HealthKit Integration**: Sync with Apple Health
- **Apple Watch**: Companion watch app
- **Notifications**: Daily workout reminders

### Advanced Features
- **Charts**: Progress visualization over time
- **Streaks**: Track consecutive workout days
- **Achievements**: Milestone badges and rewards
- **Social**: Share progress with friends
- **Custom Workouts**: User-defined exercise routines

## File Structure Reference

```
HundredsApp.xcodeproj
├── HundredsApp/
│   ├── HundredsAppApp.swift         # App entry point
│   ├── ContentView.swift            # Main tab container
│   ├── Models/
│   │   ├── Exercise.swift
│   │   ├── WorkoutDay.swift
│   │   └── ExerciseType.swift
│   ├── ViewModels/
│   │   ├── WorkoutViewModel.swift
│   │   └── CalendarViewModel.swift
│   ├── Views/
│   │   ├── Workout/
│   │   │   ├── WorkoutView.swift
│   │   │   └── ExerciseCard.swift
│   │   └── Calendar/
│   │       ├── CalendarView.swift
│   │       ├── CalendarGrid.swift
│   │       └── DayDetailView.swift
│   ├── Core Data/
│   │   ├── DataController.swift
│   │   ├── HundredsModel.xcdatamodeld
│   │   └── CoreDataExtensions.swift
│   ├── Utilities/
│   │   ├── DateExtensions.swift
│   │   ├── Constants.swift
│   │   └── Formatters.swift
│   └── Resources/
│       ├── Assets.xcassets
│       └── Info.plist
└── HundredsAppTests/
    ├── WorkoutViewModelTests.swift
    ├── DataControllerTests.swift
    └── DateExtensionTests.swift
```

## Next Steps

1. **Review and Approve Plan**: Confirm this approach meets your requirements
2. **Set Up Development Environment**: Ensure Xcode 15+ is installed
3. **Begin Implementation**: Start with Phase 1 (Project Setup and Data Models)
4. **Iterative Development**: Build and test each phase incrementally
5. **Regular Reviews**: Check progress against success criteria

This plan provides a solid foundation for converting your excellent web app into a native iOS experience while maintaining the core functionality that makes "Hundreds" effective for workout tracking.