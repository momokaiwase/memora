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
    static func saveEntry(entry: Entry) async -> String? { //returns nil if effort fails, otherwise return entry.id
        let db = Firestore.firestore()
        
        if let id = entry.id { //if true, entry exists
            do {
                try db.collection("entries").document(id).setData(from: entry)
                print("😎 Data updated successfully!")
                return id
            } catch {
                print("😡 Could not update data in 'entries' \(error.localizedDescription)")
                return id
            }
        } else { //we need to add a new spot & create a new id / document name
            do {
                let docRef = try db.collection("entries").addDocument(from: entry)
                print("🐣 Data added successfully!")
                return docRef.documentID
            } catch {
                print("😡 Could not create a new entry in 'entries' \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteEntry(entry: Entry) {
        let db = Firestore.firestore()
        guard let id = entry.id else {
            print("No entry.id")
            return
        }
        Task {
            do {
                try await db.collection("entries").document(id).delete()
            } catch {
                print("😡 Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}
