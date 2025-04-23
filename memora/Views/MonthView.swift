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
    @FirestoreQuery(collectionPath: "entries") var entries: [Entry] //loads all "entries" documents into an array var named entries
    @State private var selectedDate: DateComponents?
    @State private var selectedEntry: Entry?
    
    var body: some View {
        NavigationStack {
            Group {
                CalendarWrapper{dateComponents in
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
                            selectedEntry = Entry(date: startOfDay, text: "")
                        }
                    }
                }
                .frame(height: 400)
            }
            //.navigationTitle("month")
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
    }
}

#Preview {
    MonthView()
}
