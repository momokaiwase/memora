//
//  EntryView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import PhotosUI

struct EntryView: View {
    @FirestoreQuery(collectionPath: "entries") var fsPhotos: [Photo]
    @State var entry: Entry //pass in value from ListView
    
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false //alert if they need to save entry
    
    @State private var alertMessage = "Cannot add a Photo until you save the Spot."
    private var photos: [Photo] {
        //if running in Preview then show mock data
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return [Photo.preview, Photo.preview, Photo.preview, Photo.preview, Photo.preview, Photo.preview]
        }
        //Else show Firebase Data
        return fsPhotos
    }
    
    @State private var photo = Photo()
    @State private var data = Data() //take image data & convert into data to save it
    //@State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsPresented = false //switch to true
    //@State private var selectedImage = Image(systemName: "photo")
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var selectedImageData: [Data] = []
    
    @State private var timer: Timer?        //timer for autosave
    @State private var newChanges = false   //track changes to trigger autosave
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(entry.formattedDate)
            
            if entry.id != nil {
                Text("Last updated: \(latestChangeFormatted(for: entry))")
                    .fontWeight(.light)
            }
            
            TextField("Start journal entry of the day...", text: $entry.text, axis: .vertical)
                .padding(.horizontal)
                .onChange(of: entry.text) {
                    newChanges = true
                    startAutoSaveTimer()
                }
            
            Spacer()
            
            
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos) { photo in
                        let url = URL(string: photo.imageURLString)
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                        
                    }
                }
            }
            .frame(height: 80)
            
            Button { //button to choose photos
                if entry.id == nil {
                    showingAlert.toggle()
                } else {
                    pickerIsPresented.toggle()
                }
            } label: { //go to PhotoView
                Image(systemName: "photo.on.rectangle")
                Text("Choose Photo")
                
            }
            .bold()
            .padding()
            .tint(.main)
            
        }
        .task {
            if let entryId = entry.id {
                $fsPhotos.path = "entries/\(entryId)/photos"
            }
            //$fsPhotos.path = "entries/\(entry.id ?? "")/photos"
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveEntry()
                    timer?.invalidate()
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .status) {
                Button {
                    EntryViewModel.deleteEntry(entry: entry)
                    timer?.invalidate()
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                }
                
            }
        }
        
        //moving photoView into EntryView
        //        .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhotos)
        
        //        .onChange(of: selectedPhoto) {
        //            //turn selectedPhoto into a usable Image View
        //            Task {
        //                do {
        //                    if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
        //                        selectedImage = image
        //                    }
        //                    //get raw data from image to save to firebase Storage
        //                    guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else { print("😡 ERROR: Could not convert data from selectedPhoto.")
        //                        return
        //                    }
        //                    data = transferredData
        //                } catch {
        //                    print("😡 ERROR: Could not create Image from selectedPhoto.\(error.localizedDescription)")
        //                }
        //            }
        //        }
        .photosPicker(
            isPresented: $pickerIsPresented,
            selection: $selectedPhotos,
            maxSelectionCount: 10,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotos) { newItems in
            Task {
                selectedImages = []
                selectedImageData = []
                
                for item in newItems {
                    do {
                        if let image = try await item.loadTransferable(type: Image.self) {
                            selectedImages.append(image)
                        }
                        guard let transferredData = try await item.loadTransferable(type: Data.self) else {
                            print("😡 ERROR: Could not get Data from item.")
                            return
                        }
                        selectedImageData.append(transferredData)
                        newChanges = true
                        startAutoSaveTimer()
                    } catch {
                        print("😡 ERROR loading image/data: \(error.localizedDescription)")
                    }
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                Task {
                    guard let id = await EntryViewModel.saveEntry(entry: entry) else {
                        print("ERROR: Saving entry in alert returned nil")
                        return
                    }
                    entry.id = id
                    print("entry id: \(id)")
                    pickerIsPresented.toggle()
                }
            }
        }
        //        .fullScreenCover(isPresented: $photoSheetIsPresented) {
        //            PhotoView(entry: entry)
        //        }
    }
    
    func latestChangeFormatted(for entry: Entry) -> String {
        let calendar = Calendar.current
        let isSameDay = calendar.isDate(Date.now, inSameDayAs: entry.latestChange)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .short
        
        if isSameDay {
            formatter.dateStyle = .none
        } else {
            formatter.dateStyle = .medium
        }
        
        return formatter.string(from: entry.latestChange)
    }
    
    func startAutoSaveTimer() {
        timer?.invalidate() // cancel previous timer if any
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if newChanges {
                saveEntry()
                newChanges = false
            }
        }
    }
    
    func saveEntry() {
        Task {
            entry.latestChange = Date.now
            
            guard let id = await EntryViewModel.saveEntry(entry: entry) else {
                print("ERROR: saving entry")
                return
            }
            print("entry.id: \(id)")
            print("nice Entry save!")
            
            for data in selectedImageData {
               let photo = Photo()
               await PhotoViewModel.saveImage(entry: entry, photo: photo, data: data)
               }
        }
    }
}

#Preview {
    NavigationStack {
        EntryView(entry: Entry.preview)
    }
}
