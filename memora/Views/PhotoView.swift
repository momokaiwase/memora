//
//  PhotoView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/22.
//


import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State var entry: Entry //passed in from EntryView
    //@State private var photo = Photo()
    //@State private var data = Data() //need to take image data and convert into data to save it
    @State private var photo = Photo()
    @State private var data = Data() //take image data & convert into data to save it
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsPresented = true //switch to true
    @State private var selectedImage = Image(systemName: "photo")
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            
            Spacer()
            
            selectedImage
                .resizable()
                .scaledToFit()
            
            Spacer()
            
//            TextField("description", text: $photo.description)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            Text("by: \(photo.reviewer), on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task {
                                await PhotoViewModel.saveImage(entry: entry, photo: photo, data: data)
                                dismiss()
                            }
                            
                        }
                    }
                }
//                .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
//                .onChange(of: selectedPhoto) {
//                    //turn selectedPhoto into a usable Image View
//                    Task {
//                        do {
//                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
//                                selectedImage = image
//                            }
//                            //get raw data from image to save to firebase Storage
//                            guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else { print("😡 ERROR: Could not convert data from selectedPhoto.")
//                                return
//                            }
//                            data = transferredData
//                        } catch {
//                            print("😡 ERROR: Could not create Image from selectedPhoto.\(error.localizedDescription)")
//                        }
//                    }
//                    
//                }
        }
        .padding()
    }
}

#Preview {
    PhotoView(entry: Entry())
}

