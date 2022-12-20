//
//  Extensions.swift
//  ExpenseTracker
//
//  Created by Harry Liu on 2022-12-14.
//

import Foundation
import SwiftUI

extension Color {
    static let background = Color("Background")
    static let icon = Color("Icon")
    static let text = Color("Text")
    
    static let systemBackground = Color(uiColor: .systemBackground)
}

extension DateFormatter {
    
    // lazy method
    static let numericUS : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        return formatter
    }()
}

extension String {
    func parseDate() -> Date {
        // in case of invalid string
        guard let parsedDate = DateFormatter.numericUS.date(from: self)
        else {
            return Date()
        }
        
        return parsedDate
    }
}

extension Date : Strideable {
    func formatted() -> String {
        return self.formatted(.dateTime.year().month().day())
    }
    
    func formatForModel() -> String {
        return self.formatted(.dateTime.month().day().year())
    }
}

extension Double {
    func roundedTo2Digits() -> Double {
        return (self * 100).rounded() / 100
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
