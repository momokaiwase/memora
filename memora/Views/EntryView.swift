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
import TranscriptionKit //for speech to text

struct EntryView: View {
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false //alert if they need to save entry
    
    @State private var alertMessage = "Cannot add a Photo until you save the journal entry."
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
    
    @State private var pickerIsPresented = false //switch to true
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var selectedImageData: [Data] = []
    
    @State private var timer: Timer?        //timer for autosave
    @State private var newChanges = false   //track changes to trigger autosave
    
    @State var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var animateMic = false
    @State private var speechAsText: String?
    
    @StateObject var monthViewModel = MonthViewModel()
    
    //to prevent double saving new entries
    @State private var isSaving = false
    
    @State var entry: Entry //pass in value from MonthView
    
    //paths to get photos and entries
    @FirestoreQuery var fsPhotos: [Photo]
    @FirestoreQuery var entries: [Entry]
    init(entry: Entry) {
        _entry = State(initialValue: entry)
        
        // use userId from the entry itself
        let userId = entry.userID
        
        _fsPhotos = FirestoreQuery(collectionPath: "users/\(userId)/entries")
        _entries = FirestoreQuery(collectionPath: "users/\(userId)/entries")
    }
    
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text(entry.formattedDate)
            
            if entry.id != nil {
                Text("Last updated: \(latestChangeFormatted(for: entry))")
                    .fontWeight(.light)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    TextField("Start journal entry of the day...", text: $entry.text, axis: .vertical)
                        .padding(.horizontal)
                        .onChange(of: entry.text) {
                            newChanges = true
                            startAutoSaveTimer()
                        }
                    //Spacer()
                }
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
            
            HStack {
                
                Spacer()
                
                Button { //button to choose photos
                    if entry.id == nil {
                        showingAlert.toggle()
                    } else {
                        pickerIsPresented.toggle()
                    }
                } label: { //go to PhotoView
                    Image(systemName: "photo.on.rectangle")
                    //Text("Photos")
                }
                .bold()
                .tint(.main)
                .font(.system(size: 23))
                
                Spacer()
                
                Button {
                    if !isRecording { //first time button is pressed, isRecording = true, starts transcribing
                        speechRecognizer.resetTranscript()
                        speechRecognizer.startTranscribing()
                        isRecording = true
                        animateMic = true
                    } else {           //2nd time: isRecording so then stop transcribing
                        speechRecognizer.stopTranscribing()
                        isRecording = false
                        animateMic = false
                        entry.text += " " + speechRecognizer.transcript
                    }
                } label: {
                    Image(systemName: animateMic ? "microphone.fill" : "microphone")
                    //.font(.system(size: 40))
                        .scaleEffect(isRecording && animateMic ? 1.4 : 1.0)
                    //.foregroundColor(isRecording ? .red : .primary)
                        .animation(animateMic ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true): .default, value: animateMic)
                }
                .font(.system(size: 23))
                .bold()
                .tint(.main)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .task {
            let userId = entry.userID
            if let entryId = entry.id {
                $fsPhotos.path = "users/\(userId)/entries/\(entryId)/photos"
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
                .tint(Color("SubColor"))
            }
        }
        
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
                .tint(.main)
            Button("Save") {
                Task {
                    guard let id = await EntryViewModel.saveEntry(entry: entry) else {
                        print("ERROR: Saving entry in alert returned nil")
                        return
                    }
                    entry.id = id
                    print("entry id: \(id)")
                    pickerIsPresented.toggle()
                } //ISSUE: NEW ENTRIES DOUBLE SAVING FOR SOME REASON
            }
        }
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
        guard !isSaving else {return}
        isSaving = true
        
        Task {
            entry.latestChange = Date.now
            
            //save entry
            guard let id = await EntryViewModel.saveEntry(entry: entry) else {
                print("ERROR: saving entry")
                return
            }
            print("entry.id: \(id)")
            print("nice Entry save!")
            
            //save images
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
