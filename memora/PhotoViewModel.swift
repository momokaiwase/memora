//
//  PhotoViewModel.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/22.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class PhotoViewModel {
    static func saveImage(entry: Entry, photo: Photo, data: Data) async {
        
        guard let id = entry.id else {
            print("😡 ERROR: Should never have been called without a valid entry.id")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        if photo.id == nil {
            photo.id = UUID().uuidString //create unique filename for photo about to be saved
        }
        metadata.contentType = "image/jpeg" //allow image to be viewed in browser from Firestore console
        let path = "\(id)/\(photo.id ?? "n/a")" //id is name of Spot document (spot.id). all photos for a spot will be saved in a "folder" w its spot doc name
        
        do {
            let storageref = storage.child(path)
            let returnedMetaData = try await storageref.putDataAsync(data, metadata: metadata) //save data to storage using async method
            print("😎 SAVED \(returnedMetaData)")
            
            //getURL that we'll use to load the image
            guard let url = try? await storageref.downloadURL() else {
                print("😡 ERROR: Could not get downloadURL")
                return
            }
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            //now that photo file is saved to Storage, save a Photo document to the spot.id's "photos" collection
            let db = Firestore.firestore()
            do {
                try db.collection("entries").document(id).collection("photos").document(photo.id ?? "n/a").setData(from: photo)
            } catch {
                print("😡 Could not update data in spots/\(id)/photos/\(photo.id ?? "n/a").\(error.localizedDescription)")
            }
        } catch {
            print("😡 ERROR saving photo to Storage \(error.localizedDescription)")
        }
        
    }
}
