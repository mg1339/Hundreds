//
//  DateExtensions.swift
//  Hundreds
//
//  Created on 2025-01-26.
//

import Foundation

extension Date {
    /// Returns the start of the day for this date
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Returns the end of the day for this date
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Returns true if this date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Returns true if this date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Returns true if this date is tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Returns the date formatted as "yyyy-MM-dd"
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// Returns the date formatted for display (e.g., "Monday, January 15, 2025")
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: self)
    }
    
    /// Returns the date formatted as "MMM d" (e.g., "Jan 15")
    var shortDisplayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Returns the month and year formatted as "January 2025"
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    /// Returns the day of the month as an integer
    var dayOfMonth: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// Returns the month as an integer (1-12)
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// Returns the year as an integer
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// Returns the weekday as an integer (1 = Sunday, 2 = Monday, etc.)
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    /// Returns a new date by adding the specified number of days
    func addingDays(_ days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Returns a new date by adding the specified number of months
    func addingMonths(_ months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// Returns the first day of the month for this date
    var firstDayOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    /// Returns the last day of the month for this date
    var lastDayOfMonth: Date {
        let firstDay = firstDayOfMonth
        let nextMonth = firstDay.addingMonths(1)
        return nextMonth.addingDays(-1)
    }
    
    /// Returns the number of days in the month for this date
    var daysInMonth: Int {
        let range = Calendar.current.range(of: .day, in: .month, for: self)
        return range?.count ?? 30
    }
    
    /// Returns true if this date is in the same day as the other date
    func isSameDay(as other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    /// Returns true if this date is in the same month as the other date
    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: self) == calendar.component(.month, from: other) &&
               calendar.component(.year, from: self) == calendar.component(.year, from: other)
    }
    
    /// Returns the number of days between this date and another date
    func daysBetween(_ other: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfOther = calendar.startOfDay(for: other)
        let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfOther)
        return components.day ?? 0
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    /// Returns the date interval for the given month
    func monthInterval(for date: Date) -> DateInterval? {
        return dateInterval(of: .month, for: date)
    }
    
    /// Returns all dates in the given month
    func datesInMonth(for date: Date) -> [Date] {
        guard let monthInterval = monthInterval(for: date) else { return [] }
        
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate) ?? monthInterval.end
        }
        
        return dates
    }
}