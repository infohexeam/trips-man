//
//  LocalizationStrings.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/07/23.
//

import Foundation

struct L {
    static func reviewedByText(by customerName: String, on reviewDate: String) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return ""
        } else {
            return "- Reviewed by \(customerName) on \(reviewDate)"
        }
    }
    
    static func addGuestValidationMessage(guestCount: Int) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return ""
        } else {
            if guestCount == 1 {
                return "You have selected only 1 person"
            } else {
                return "You have selected only \(guestCount) people"
            }
        }
    }
    
    static func roomAndGuestCountText(roomCount: Int, adultCount: Int, childCount: Int) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return ""
        } else {
            return "\(roomCount.oneOrMany("Room")) for \(adultCount.oneOrMany("Adult")) and \(childCount.oneOrMany("Child", suffix: "ren"))"
        }
    }
}
