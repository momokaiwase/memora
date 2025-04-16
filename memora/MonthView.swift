//
//  MonthView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MonthView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Group {
                //put calendar here
            }
            .navigationTitle("month")
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
