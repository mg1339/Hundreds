//
//  Constants.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation
import SwiftUI

// MARK: - App Constants
struct AppConstants {
    static let appName = "Hundreds"
    static let appVersion = "1.0"
    static let buildNumber = "1"
    
    // Core Data
    static let coreDataModelName = "HundredsModel"
    
    // User Defaults Keys
    static let lastOpenDateKey = "lastOpenDate"
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let preferredThemeKey = "preferredTheme"
    
    // Notification Identifiers
    static let dailyReminderNotificationId = "dailyReminder"
    static let workoutCompleteNotificationId = "workoutComplete"
}

// MARK: - Exercise Constants
struct ExerciseConstants {
    // Default targets
    static let defaultPushupsTarget: Double = 100
    static let defaultSitupsTarget: Double = 100
    static let defaultSquatsTarget: Double = 100
    static let defaultRunningTarget: Double = 10.0
    
    // Increments
    static let defaultExerciseIncrement: Double = 1
    static let runningIncrement: Double = 0.1
    
    // Limits
    static let maxExerciseValue: Double = 999
    static let maxRunningValue: Double = 99.9
    static let minValue: Double = 0
    
    // Display
    static let exerciseDecimalPlaces = 0
    static let runningDecimalPlaces = 1
    static let runningUnit = "mi"
}

// MARK: - UI Constants
struct UIConstants {
    // Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16
    static let extraLargeCornerRadius: CGFloat = 20
    
    // Button Sizes
    static let counterButtonSize: CGFloat = 44
    static let smallButtonHeight: CGFloat = 36
    static let mediumButtonHeight: CGFloat = 44
    static let largeButtonHeight: CGFloat = 52
    
    // Progress Indicators
    static let progressBarHeight: CGFloat = 6
    static let circularProgressLineWidth: CGFloat = 8
    static let largeCircularProgressLineWidth: CGFloat = 12
    
    // Card Dimensions
    static let exerciseCardMinHeight: CGFloat = 140
    static let calendarDaySize: CGFloat = 45
    static let calendarDayHeight: CGFloat = 60
    
    // Animation Durations
    static let shortAnimationDuration: Double = 0.2
    static let mediumAnimationDuration: Double = 0.3
    static let longAnimationDuration: Double = 0.5
    
    // Shadow
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Double = 0.1
    static let shadowOffset = CGSize(width: 0, height: 2)
}

// MARK: - Color Constants
struct ColorConstants {
    // Progress Colors
    static let completeColor = Color.green
    static let partialColor = Color.orange
    static let incompleteColor = Color.blue
    static let noProgressColor = Color.gray
    
    // Status Colors
    static let successColor = Color.green
    static let warningColor = Color.orange
    static let errorColor = Color.red
    static let infoColor = Color.blue
    
    // Background Colors
    static let primaryBackgroundColor = Color(.systemBackground)
    static let secondaryBackgroundColor = Color(.systemGray6)
    static let tertiaryBackgroundColor = Color(.systemGray5)
    
    // Text Colors
    static let primaryTextColor = Color.primary
    static let secondaryTextColor = Color.secondary
    static let tertiaryTextColor = Color(.systemGray)
    
    // Accent Colors
    static let primaryAccentColor = Color.blue
    static let secondaryAccentColor = Color(.systemBlue)
}

// MARK: - Font Constants
struct FontConstants {
    // Font Sizes
    static let captionSize: CGFloat = 12
    static let footnoteSize: CGFloat = 13
    static let subheadlineSize: CGFloat = 15
    static let calloutSize: CGFloat = 16
    static let bodySize: CGFloat = 17
    static let headlineSize: CGFloat = 17
    static let title3Size: CGFloat = 20
    static let title2Size: CGFloat = 22
    static let title1Size: CGFloat = 28
    static let largeTitleSize: CGFloat = 34
    
    // Font Weights
    static let lightWeight = Font.Weight.light
    static let regularWeight = Font.Weight.regular
    static let mediumWeight = Font.Weight.medium
    static let semiboldWeight = Font.Weight.semibold
    static let boldWeight = Font.Weight.bold
    static let heavyWeight = Font.Weight.heavy
}

// MARK: - Accessibility Constants
struct AccessibilityConstants {
    // Identifiers
    static let exerciseCardIdentifier = "exerciseCard"
    static let incrementButtonIdentifier = "incrementButton"
    static let decrementButtonIdentifier = "decrementButton"
    static let inputFieldIdentifier = "inputField"
    static let calendarDayIdentifier = "calendarDay"
    static let progressIndicatorIdentifier = "progressIndicator"
    
    // Labels
    static let incrementButtonLabel = "Increment exercise count"
    static let decrementButtonLabel = "Decrement exercise count"
    static let inputFieldLabel = "Enter exercise count"
    static let progressIndicatorLabel = "Exercise progress"
    static let calendarDayLabel = "Calendar day"
    
    // Hints
    static let exerciseCardHint = "Double tap to edit count directly"
    static let calendarDayHint = "Tap to view workout details"
    static let progressHint = "Shows completion percentage"
}

// MARK: - Validation Constants
struct ValidationConstants {
    // Input Validation
    static let maxInputLength = 5
    static let allowedNumberCharacters = CharacterSet(charactersIn: "0123456789.")
    
    // Value Ranges
    static let exerciseValueRange = 0...999
    static let runningValueRange = 0.0...99.9
    
    // Formatting
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    static let integerFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

// MARK: - Calendar Constants
struct CalendarConstants {
    static let daysInWeek = 7
    static let maxWeeksInMonth = 6
    static let weekdaySymbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let monthSymbols = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
}

// MARK: - Notification Constants
struct NotificationConstants {
    // Categories
    static let workoutReminderCategory = "WORKOUT_REMINDER"
    static let achievementCategory = "ACHIEVEMENT"
    
    // Actions
    static let markCompleteAction = "MARK_COMPLETE"
    static let snoozeAction = "SNOOZE"
    static let viewProgressAction = "VIEW_PROGRESS"
    
    // Default reminder time (8:00 AM)
    static let defaultReminderHour = 8
    static let defaultReminderMinute = 0
}