//
//  EntryView.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/15.
//

import SwiftUI

struct EntryView: View {
    @State var entry: Entry //pass in value from ListView
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text(entry.formattedDate)
            
            TextField("Start journal entry of the day...", text: $entry.text, axis: .vertical)
                .padding(.horizontal)
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    //TODO: add save code here
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EntryView(entry: Entry())
    }
}
