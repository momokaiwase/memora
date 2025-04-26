//
//  MonthView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct MonthView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var userID: String = Auth.auth().currentUser?.uid ?? ""
    @FirestoreQuery(collectionPath: "placeholder") var entries: [Entry] //placeholder path - will loadd all "entries" documents into an array var named entries
    
    @State private var selectedDate: DateComponents?
    @State private var selectedEntry: Entry?
    
    @State private var displayedYear: Int = Calendar.current.component(.year, from: Date()) // Default to current year
    @State private var displayedMonth: Int = Calendar.current.component(.month, from: Date()) // Default to current month
    //@State private var entriesCount: Int = 0
    @State private var totalDays: Int = 0
    @StateObject var monthViewModel = MonthViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                CalendarWrapper(
                    
                    onDateSelected: { dateComponents in
                        //dateComponents is components (year, month, date, etc.) of selected date
                        //selected converts DateComponents into Date object
                        if let selected = Calendar.current.date(from: dateComponents) {
                            
                            //get current calendar (Gregorian, time zone, etc.)
                            let calendar = Calendar.current
                            
                            //get day (without time components using startOfDay)
                            let startOfDay = calendar.startOfDay(for: selected)
                            
                            //look through entries array and find the first Entry
                            //where the Entry has the same date w/o time as startOfDay defined above (selected date)
                            if let existingEntry = entries.first(where: {
                                calendar.isDate(calendar.startOfDay(for: $0.date), inSameDayAs: startOfDay)
                            }) {
                                // Load existing entry
                                selectedEntry = existingEntry
                            } else {
                                // Create new entry
                                selectedEntry = Entry(date: startOfDay, text: "", userID: userID)
                            }
                        }
                    },
                    
                    onMonthChanged: { visibleComponents in
                        
                        //get selected month and year
                        if let year = visibleComponents.year,
                           let month = visibleComponents.month {
                            displayedYear = year
                            displayedMonth = month
                            
                            // Calculate total days for the selected month
                            totalDays = monthViewModel.totalDaysCurMonth(year: year, month: month)
                            
                            //update count of entries
                            monthViewModel.updateCount(with: entries, year: year, month: month)
                        }
                    }
                    
                    
                )
                .frame(height: 400)
                
                // Display progress bar for the selected month
                ProgressView(value: Float(monthViewModel.curMonthEntriesCount), total: Float(totalDays))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                Text(" \(monthViewModel.curMonthEntriesCount)/\(totalDays) entries this month")
                
            }
            .navigationDestination(item: $selectedEntry) { entry in
                EntryView(entry: entry)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print("🪵➡️ Log out successful!")
                            dismiss()
                        } catch {
                            print("😡 ERROR: Could not log out")
                        }
                    }
                }
            }
        }
        .onAppear {
                if let uid = Auth.auth().currentUser?.uid {
                    userID = uid
                    $entries.path = "users/\(uid)/entries" //populate path accor to user id
                }
            }
        .task(id: entries.count) {
            monthViewModel.updateCount(with: entries, year: displayedYear, month: displayedMonth)
        }
    }
}

#Preview {
    MonthView()
}
