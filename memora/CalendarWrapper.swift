//
//  CalendarWrapper.swift
//  memora
//
//  Created by Momoka Iwase on 2025/04/16.
//

import Foundation
import SwiftUI
import UIKit

struct CalendarWrapper: UIViewRepresentable {
    //callback closure that takes in DateComponenets (date selected) and returns nothing
    var onDateSelected: (DateComponents) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDateSelected: onDateSelected)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CalendarWrapper>) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.tintColor = .main
        calendarView.availableDateRange = DateInterval(start: .distantPast, end: .now)
        
        //when a date is selected, go to delegate coordinator
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: UIViewRepresentableContext<CalendarWrapper>) {
        // update code if needed
    }
    
    // coordinator is a 'delegate' that listens for date selection events from the UICalendarView.
    // It conforms to the UICalendarSelectionSingleDateDelegate protocol,
    // allowing it to respond when a user taps a date on the calendar.
    class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
           var onDateSelected: (DateComponents) -> Void

           init(onDateSelected: @escaping (DateComponents) -> Void) {
               self.onDateSelected = onDateSelected
           }
        
        //delegate method that runs when user taps on date
           func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
               
               //check if date was selected
               guard let dateComponents = dateComponents else { return }
               
               //trigger callback (code inside CalendarWrapper{} in view runs)
               onDateSelected(dateComponents)
               
           }
       }
}
