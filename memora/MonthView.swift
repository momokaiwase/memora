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

struct MonthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: DateComponents?

    var body: some View {
        NavigationStack {
            Group {
                CalendarWrapper{dateComponents in
                   //TODO: lead to entryView
//                //convert DateComponents to Date
//                    if let date = Calendar.current.date(from: dateComponents) {
//                        let entry = Entry(date: date, text: "")
//                        selectedEntry = entry
//                    }
                }
                    .frame(height: 400)
            }
            //.navigationTitle("month")
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
