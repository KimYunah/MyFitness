//
//  DateManager.swift
//  MyFitness
//
//  Created by UMCios on 2023/05/10.
//

import Foundation

class DateManager {
    private(set) var currentDate: Date

    var components: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
    }
    init(_ date: Date = Date()) {
        currentDate = date
    }
    
    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        currentDate = calendar.date(from: dateComponents)!
    }

    private func moveToFirstDayOfMonth() {
        if let firstDayOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: currentDate)) {
            currentDate = firstDayOfMonth
        }
    }

    func moveToPreviousMonth() {
        var previousMonthComponents = DateComponents()
        previousMonthComponents.month = -1
        if let previousMonth = Calendar.current.date(byAdding: previousMonthComponents, to: currentDate) {
            currentDate = previousMonth
            moveToFirstDayOfMonth()
        }
    }

    func moveToNextMonth() {
        var nextMonthComponents = DateComponents()
        nextMonthComponents.month = 1
        if let nextMonth = Calendar.current.date(byAdding: nextMonthComponents, to: currentDate) {
            currentDate = nextMonth
            moveToFirstDayOfMonth()
        }
    }

    func firstDayOfMonthWeekday() -> Int? {
        let dateComponents = Calendar.current.dateComponents([.weekday], from: currentDate)
        return dateComponents.weekday
    }
    
    static func getWeekdayForDate(year: Int, month: Int, day: Int) -> Int? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        if let date = calendar.date(from: dateComponents) {
            let weekdayComponents = calendar.dateComponents([.weekday], from: date)
            return weekdayComponents.weekday
        } else {
            return nil
        }
    }

}
/*
// Usage
let dateManager = DateManager()

if let weekday = dateManager.firstDayOfMonthWeekday() {
    print("Current month, first day's weekday: \(weekday)")
} else {
    print("Error calculating weekday")
}

dateManager.moveToPreviousMonth()
if let weekday = dateManager.firstDayOfMonthWeekday() {
    print("Previous month, first day's weekday: \(weekday)")
} else {
    print("Error calculating weekday")
}

dateManager.moveToNextMonth()
if let weekday = dateManager.firstDayOfMonthWeekday() {
    print("Next month, first day's weekday: \(weekday)")
} else {
    print("Error calculating weekday")
}

*/
