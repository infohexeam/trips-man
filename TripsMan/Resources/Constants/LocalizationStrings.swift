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
    
    static func redeemRewardPointText(percentage: Double, maxAmount: Double) -> String {
        if SessionManager.shared.getLanguage().code == "ar" {
            return ""
        } else {
            return "Redeem \(percentage)% of your wallet points. Maximum redeem amount on this booking is \(SessionManager.shared.getCurrency()) \(maxAmount)"
        }
    }
    
    static func bookingSuccessMessage(for module: String, with bookingNo: String) -> String {
        return "Your \(K.getModuleText(of: module)) booking has been successfully confirmed. Enjoy your experience! Booking No: \(bookingNo)"
    }
    
    static func paymentWaitingMessage(for module: String, with bookingNo: String) -> String {
        return "Your \(K.getModuleText(of: module)) booking has been successfully confirmed. And payment verification is in process. If you have any questions or need assistance, contact our admin at \(K.adminContactNo) or \(K.adminContactEmail) Booking No: \(bookingNo)"
    }
    
    static func bookingFailedMessage() -> String {
        return "We apologise, but there seems to be an issue with your booking. Unfortunately, the booking could not be confirmed at this time. We recommend contacting our support team for further assistance. We apologize for any inconvenience caused. Contact us at \(K.adminContactNo) or \(K.adminContactEmail)"
    }
}
