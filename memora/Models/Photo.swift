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
    var user: String = Auth.auth().currentUser?.email ?? ""
    var addedOn = Date() //current date/time

    init(id: String? = nil, imageURLString: String = "", description: String = "", user: String = (Auth.auth().currentUser?.email ?? ""), addedOn: Date = Date()) {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
        self.user = user
        self.addedOn = addedOn
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo( //ctrl m to format specifiers on diff lines
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Pizza-3007395.jpg/500px-Pizza-3007395.jpg",
            description: "Yummy Pizza",
            user: "little@caesars.com",
            addedOn: Date()
        )
        return newPhoto
    }
}
