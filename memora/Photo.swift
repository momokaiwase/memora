//
//  Photo.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/22.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" //holds URL for loading image
    var description = ""
    var reviewer: String = Auth.auth().currentUser?.email ?? ""
    var addedOn = Date() //current date/time
}
