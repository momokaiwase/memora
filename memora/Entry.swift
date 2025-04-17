//
//  Entry.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import Foundation
import FirebaseFirestore

struct Entry: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var date = Date()
    var text = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from:date)
    }
}
