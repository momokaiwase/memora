//
//  EntryViewModel.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/17.
//

import Foundation
import FirebaseFirestore

@Observable
class EntryViewModel {
    func saveEntry(entry: Entry) -> Bool {
        let db = Firestore.firestore()
        
        if let id = entry.id { //if true, entry exists
            do {
                try db.collection("entries").document(id).setData(from: entry)
                print("😎 Data updated successfully!")
                return true
            } catch {
                print("😡 Could not update data in 'entries' \(error.localizedDescription)")
                return false
            }
        } else { //we need to add a new spot & create a new id / document name
            do {
                try db.collection("entries").addDocument(from: entry)
                print("🐣 Data added successfully!")
                return true
            } catch {
                print("😡 Could not create a new entry in 'entries' \(error.localizedDescription)")
                return false
            }
        }
    }
}
