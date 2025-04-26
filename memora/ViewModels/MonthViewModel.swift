//
//  MonthViewModel.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/25.
//

import Foundation

//@Observable
class MonthViewModel: ObservableObject {
    @Published var curMonthEntriesCount: Int = 0
    
    func totalDaysCurMonth(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        
        // Start and end of the month
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let nextMonth = month + 1
        let startOfNextMonth = calendar.date(from: DateComponents(year: year, month: nextMonth, day: 1))!
        
        // Calculate number of days in the month
        let numberOfDays = calendar.dateComponents([.day], from: startOfMonth, to: startOfNextMonth).day!
        return numberOfDays
    }
    
    // Update count of entries for the given month and year
    func updateCount(with entries: [Entry], year: Int, month: Int) {
        let filteredEntriesCount = entries.filter {
            let entryMonth = Calendar.current.component(.month, from: $0.date)
            let entryYear = Calendar.current.component(.year, from: $0.date)
            return entryMonth == month && entryYear == year
        }.count
        
        // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                self.curMonthEntriesCount = filteredEntriesCount
            }
    }
}
