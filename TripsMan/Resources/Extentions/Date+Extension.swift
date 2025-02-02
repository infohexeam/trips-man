//
//  Date+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 01/10/22.
//

import Foundation

extension Date {
    func stringValue(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "ar")
        return dateFormatter.string(from: self)
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func numberOfDays(to: Date) -> Int {
        let fromDate = Calendar.current.startOfDay(for: self)
        let toDate = Calendar.current.startOfDay(for: to)
        let numberOfDays = Calendar.current.dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }
}

extension String {
    func date(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension Calendar {
    
}
