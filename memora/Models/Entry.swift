//
//  Entry.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Entry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var date = Date()
    var latestChange = Date()
    var text = ""
    var userID: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from:date)
    }
}

extension Entry {
    static var preview: Entry {
        let newEntry = Entry(id: "1", date: Date(), latestChange: Date(), text: "I went to Boston Public Market", userID: "test")
        return newEntry
    }
}
