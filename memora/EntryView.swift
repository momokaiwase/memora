//
//  EntryView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct EntryView: View {
    @FirestoreQuery(collectionPath: "entries") var photos: [Photo]
    @State var entry: Entry //pass in value from ListView
    @Environment(\.dismiss) private var dismiss
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false //alert if they need to save entry
    @State private var alertMessage = "Cannot add a Photo until you save the Spot."
    var body: some View {
        VStack {
            Text(entry.formattedDate)
            
            TextField("Start journal entry of the day...", text: $entry.text, axis: .vertical)
                .padding(.horizontal)
            
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
            
            Button { //photo button
                if entry.id == nil {
                    showingAlert.toggle()
                } else {
                    photoSheetIsPresented.toggle()
                }
            } label: { //go to PhotoView
                Image(systemName: "camera.fill")
                Text("Photo")
            }
            .bold()
            .padding()
            .tint(.main)

        }
        .task {
            $photos.path = "entries/\(entry.id ?? "")/photos"
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveEntry()
                    dismiss()
                }
            }
            ToolbarItem(placement: .status) {
                Button {
                    EntryViewModel.deleteEntry(entry: entry)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
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
                    photoSheetIsPresented.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $photoSheetIsPresented) {
            PhotoView(entry: entry)
        }
    }
    
    func saveEntry() {
        Task {
            guard let id = await EntryViewModel.saveEntry(entry: entry) else {
                print("ERROR: saving entry from Save button")
                return
            }
            print("entry.id: \(id)")
            print("nice Entry save!")
        }
    }
}

#Preview {
    NavigationStack {
        EntryView(entry: Entry(id: "1", date: Date(), text: "hi"))
    }
}
