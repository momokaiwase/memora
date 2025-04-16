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
    func makeUIView(context: UIViewRepresentableContext<CalendarWrapper>) -> UICalendarView {
        let calendarView = UICalendarView()
                calendarView.tintColor = .systemMint
                calendarView.availableDateRange = DateInterval(start: .now, end: .distantFuture)
                return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: UIViewRepresentableContext<CalendarWrapper>) {
        // update code if needed
    }
}
