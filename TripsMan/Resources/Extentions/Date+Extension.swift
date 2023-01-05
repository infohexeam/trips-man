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
        return dateFormatter.string(from: self)
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
