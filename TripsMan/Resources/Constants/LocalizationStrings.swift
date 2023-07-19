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
        if guestCount == 1 {
            self.view.makeToast("You have selected only 1 person".localized())
        } else {
            self.view.makeToast("You have selected only \(totalGuests) people")
        }
    }
}
