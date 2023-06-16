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
    static let otpTimer = 10
    
    static let minimumPrice: Double = 0
    static let maximumPrice: Double = 100000
    
    static let couponToShow = 4
    static let readMoreContentLines = 5
    
    static let genders = ["Male", "Female", "Prefer not to say"]
    
    static let countryCodes: [MobileCodes] = [MobileCodes(code: "+91", mobileLength: 10),
                                              MobileCodes(code: "+971", mobileLength: 9)]
    
    static let hotelPlaceHolderImage = "hotel-default-img"
    static let packagePlaceHolderImage = "pack-default-img"
    static let activityPlaceholderImage = "activity-default-img"
    static let meetupPlaceholderImage = "meetup-default-img"
    
    static let defaultRoomCount = 1
    static let defaultAdultCount = 2
    static let defaultChildCount = 0
    
    static let otpSentSuccessMessage = "Successfully sent OTP"
    static let otpFailureMessage = "OTP is invalid or expired"
    
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
