//
//  Constants.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/10/22.
//

import Foundation

let baseURLAuth = "https://tripsmanauth.hexeam.in/"
let baseURL = "https://tripsmanadmin.hexeam.in/"


struct K {
    
    static let razorpayKey = "rzp_test_wcxqh0E3miedHg"
    
    static let otpTimer = 10
    
    static let minimumPrice: Double = 0
    static let maximumPrice: Double = 100000
    
    static let couponToShow = 4
    static let readMoreContentLines = 5
    
    static let genders = ["Male", "Female", "Prefer not to say"]
    
    static let countryCodes: [MobileCodes] = [MobileCodes(code: "+91", mobileLength: 10),
                                              MobileCodes(code: "+971", mobileLength: 9)]
    
    //Country Selection
    //  localeIdentifier uses in:
    //      - setting country w.r.t device's locale identifier (MainViewController)
    //      - Google Maps country filter (DefaultFilterViewController)
    //  countryCode uses in tripsman apis
    static let countries = [CountrySelection(name: "India", icon: "country-india", countryCode: "IND", localeIdentifier: "IN", currency: "INR", id: 1),
                            CountrySelection(name: "UAE", icon: "country-uae", countryCode: "UAE", localeIdentifier: "AE", currency: "AED", id: 2)]
    static let languages = [LanguageSelection(name: "English", id: 1)]
    
    static let hotelPlaceHolderImage = "hotel-default-img"
    static let packagePlaceHolderImage = "pack-default-img"
    static let activityPlaceholderImage = "activity-default-img"
    static let meetupPlaceholderImage = "meetup-default-img"
    
    static let adminContactNo = "99XXXXXXXX"
    static let adminContactEmail = "adminxxxxx@tripsman.com"
    
    static let defaultRoomCount = 1
    static let defaultAdultCount = 2
    static let defaultChildCount = 0
    
    static let otpSentSuccessMessage = "Successfully sent OTP"
    static let otpFailureMessage = "OTP is invalid or expired"
    
    
    
    static let paymentVerifyingMessage = "Authentication your transaction.. Please do not close the app."
    static let confirmBookingmMessage = "Finalizing your booking. Almost there!"
    
    static func getBookingSuccessMessage(for module: String, with bookingNo: String) -> String {
        return "Your \(getModuleText(of: module)) booking has been successfully confirmed. Enjoy your experience! Booking No: \(bookingNo)"
    }
    
    static func getPaymentWaitingMessage(for module: String, with bookingNo: String) -> String {
        return "Your \(getModuleText(of: module)) booking has been successfully confirmed. And payment verification is in process. If you have any questions or need assistance, contact our admin at \(adminContactNo) or \(adminContactEmail) Booking No: \(bookingNo)"
    }
    
    static func getBookingFailedMessage() -> String {
        return "We apologise, but there seems to be an issue with your booking. Unfortunately, the booking could not be confirmed at this time. We recommend contacting our support team for further assistance. We apologize for any inconvenience caused. Contact us at \(adminContactNo) or \(adminContactEmail)"
    }
    
    static func getModuleCode(of listType: ListType) -> String {
        switch listType {
        case .hotel:
            return "HTL"
        case .packages:
            return "HDY"
        case .activities:
            return "ACT"
        case .meetups:
            return "MTP"
        }
    }
    
    static func getModuleText(of moduleCode: String) -> String {
        switch moduleCode {
        case "HTL":
            return "hotel"
        case "HDY":
            return "holiday package"
        case "ACT":
            return "activity"
        case "MTP":
            return "meetup"
        default:
            return ""
        }
    }
    
    static func getCouponText(with description: String, minAmount: Double, discount: Double, discountType: Int) -> String {
        // Discount types: 1 - Fixed
        //                 2 - Percentage
        var discountText = ""
        if discountType == 1 {
            discountText = "\(SessionManager.shared.getCurrency()) \(discount)"
        } else if discountType == 2 {
            discountText = "\(discount)%"
        }
        
        return "\(description)\nMin. Order Value: \(SessionManager.shared.getCurrency()) \(minAmount), Discount: \(discountText) "
    }
    
    
}

struct MobileCodes {
    var code: String
    var mobileLength: Int
}

//Validation Messages
struct Validation {
    //HOTEL
    static let htlPrimaryGuestDetails = "Enter primary guest details"
//    static let htlGuestDetails
    
    //Holiday Package
    static let hdyStartDateSelection = "Select start date"
    static let hdyPrimaryTravellerDetails = "Enter primary traveller details"
    static let hdyPrimaryTravellerName = "Enter primary traveller name"
    static let hdyPrimaryTravellerContact = "Enter primary traveller contact number"
//    static let hdyPrimaryTaveller
    
        //Activity&Meetup
    static let primaryCustomerDetails = "Enter primary customer details"
}


struct CountrySelection: Codable {
    var name: String
    var icon: String
    var countryCode: String
    var localeIdentifier: String
    var currency: String
    var id: Int
}

struct LanguageSelection {
    var name: String
    var id: Int
}
