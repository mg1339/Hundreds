# Hundreds iOS App

A native iOS app for tracking your daily "Hundreds" workout routine: 100 pushups, 100 situps, 100 squats, and 10 mile run.

## 📱 Overview

This iOS app is a native Swift/SwiftUI conversion of the original Hundreds web app, designed to provide the best possible mobile experience for workout tracking.

## 🏗 Architecture

### Technology Stack
- **Framework**: SwiftUI (iOS 15+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: Core Data
- **Navigation**: NavigationStack with TabView
- **Date Handling**: Foundation Date and Calendar APIs

### Project Structure
```
HundredsApp/
├── HundredsApp.swift           # App entry point
├── ContentView.swift           # Main tab container
├── Models/
│   ├── ExerciseType.swift      # Exercise definitions and formatting
│   └── WorkoutDay.swift        # Daily workout data model
├── ViewModels/
│   ├── WorkoutViewModel.swift  # Main workout logic and state
│   └── CalendarViewModel.swift # Calendar data management
├── Views/
│   ├── WorkoutView.swift       # Daily tracking interface
│   ├── ExerciseCard.swift      # Individual exercise counter
│   ├── CalendarView.swift      # Monthly calendar grid
│   └── DayDetailView.swift     # Individual day details
├── CoreData/
│   ├── DataController.swift    # Core Data stack management
│   ├── WorkoutDayEntity+CoreDataClass.swift
│   ├── WorkoutDayEntity+CoreDataProperties.swift
│   └── HundredsModel_README.md # Core Data model documentation
├── Utilities/
│   ├── DateExtensions.swift    # Date formatting and manipulation
│   └── Constants.swift         # App-wide constants
└── Info.plist                  # App configuration
```

## 🚀 Features

### Core Functionality
- **Daily Exercise Tracking**: Track pushups, situps, squats, and running
- **Interactive Counters**: +/- buttons and direct input fields
- **Progress Visualization**: Progress bars and circular progress indicators
- **Real-time Updates**: Automatic saving and visual feedback
- **Input Validation**: Proper bounds checking and formatting

### Calendar View
- **Monthly Grid**: Visual calendar showing workout history
- **Color-coded Days**: Green (complete), orange (partial), gray (no activity)
- **Day Details**: Tap any day to see detailed workout breakdown
- **Navigation**: Easy month-to-month browsing

### Data Management
- **Core Data Persistence**: Robust local data storage
- **Automatic Day Transitions**: Seamless midnight reset handling
- **Data Integrity**: Proper validation and error handling
- **Performance**: Optimized queries and background processing

### iOS-Specific Features
- **Native UI**: SwiftUI components with iOS design patterns
- **Haptic Feedback**: Tactile responses for milestone achievements
- **Accessibility**: Full VoiceOver and accessibility support
- **Dark Mode**: Automatic system theme adaptation
- **Pull-to-Refresh**: Standard iOS refresh patterns

## 📋 Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- macOS 12.0+ for development

### Installation Steps

1. **Create New Xcode Project**
   ```
   File → New → Project → iOS → App
   Product Name: Hundreds
   Interface: SwiftUI
   Language: Swift
   Use Core Data: ✓
   ```

2. **Add Source Files**
   - Copy all `.swift` files to your Xcode project
   - Ensure proper folder structure in Xcode navigator
   - Add files to target membership

3. **Configure Core Data Model**
   - Delete the default `.xcdatamodeld` file
   - Create new Core Data model named "HundredsModel.xcdatamodeld"
   - Follow instructions in `CoreData/HundredsModel_README.md`
   - Add WorkoutDayEntity with specified attributes

4. **Update Info.plist**
   - Replace default Info.plist with provided version
   - Verify bundle identifier and app name
   - Ensure proper permissions are set

5. **Build and Run**
   ```bash
   # In Xcode
   Product → Build (⌘+B)
   Product → Run (⌘+R)
   ```

## 🎯 Usage

### Daily Workout Tracking
1. Open the app to see today's workout interface
2. Use +/- buttons for quick increments
3. Tap input fields for direct number entry
4. Watch progress bars fill as you complete exercises
5. See motivational messages and completion status

### Calendar Navigation
1. Tap "Calendar" tab to view workout history
2. Use arrow buttons to navigate between months
3. Tap any day with data to see detailed breakdown
4. Use "Back to Today" to return to current month

### Data Persistence
- All data saves automatically as you make changes
- App handles day transitions at midnight
- Previous day's data moves to history automatically
- No manual save required

## 🔧 Customization

### Modifying Exercise Targets
Edit targets in `Models/ExerciseType.swift`:
```swift
static let pushups = ExerciseType(
    name: "pushups",
    displayName: "Pushups",
    target: 150, // Change from 100 to 150
    increment: 1,
    maxValue: 999,
    decimalPlaces: 0,
    unit: ""
)
```

### Adding New Exercises
1. Add new static property to `ExerciseType`
2. Update `allExercises` array
3. Add corresponding properties to `WorkoutDay`
4. Update Core Data model with new attributes
5. Handle data migration if needed

### UI Customization
- Modify colors in `Utilities/Constants.swift`
- Adjust spacing and sizing constants
- Update fonts and styling in individual views

## 🧪 Testing

### Unit Tests
Create test files for:
- `WorkoutViewModelTests.swift`: Test workout logic
- `CalendarViewModelTests.swift`: Test calendar functionality
- `WorkoutDayTests.swift`: Test data model methods
- `DataControllerTests.swift`: Test Core Data operations

### UI Tests
Test user interactions:
- Exercise counter functionality
- Calendar navigation
- Data persistence
- Day transitions

### Manual Testing Checklist
- [ ] Counter buttons increment/decrement correctly
- [ ] Input fields accept valid values only
- [ ] Progress bars update in real-time
- [ ] Calendar shows correct workout history
- [ ] Day detail view displays accurate data
- [ ] App handles midnight transitions
- [ ] Data persists between app launches
- [ ] Accessibility features work properly

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
- Ensure all files are added to target
- Check Core Data model configuration
- Verify iOS deployment target (15.0+)

**Core Data Issues**
- Delete app from simulator/device to reset data
- Check entity names match code references
- Verify attribute types and optionality

**UI Layout Problems**
- Test on different device sizes
- Check constraint priorities
- Verify safe area handling

**Performance Issues**
- Profile with Instruments
- Check for retain cycles in ViewModels
- Optimize Core Data fetch requests

## 🔮 Future Enhancements

### Phase 2 Features
- **Themes**: Multiple color schemes
- **Data Export/Import**: JSON backup functionality
- **Widgets**: Home screen widgets for quick progress view
- **Shortcuts**: Siri shortcuts for logging workouts
- **HealthKit Integration**: Sync with Apple Health
- **Apple Watch**: Companion watch app

### Advanced Features
- **Charts**: Progress visualization over time
- **Streaks**: Track consecutive workout days
- **Achievements**: Milestone badges and rewards
- **Social**: Share progress with friends
- **Custom Workouts**: User-defined exercise routines
- **Push Notifications**: Daily workout reminders

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

---

**Ready to build your hundreds? 💪**

This iOS app provides a native, performant, and delightful way to track your daily workout progress!