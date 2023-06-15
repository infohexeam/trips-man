//
//  HolidayTripDetails.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/05/23.
//

import Foundation

// MARK: - HolidayTripDetailsData
struct HolidayTripDetailsData: Codable {
    let data: HolidayTripDetails
    let status: Int
    let message: String
}

// MARK: - HolidayTripDetails
struct HolidayTripDetails: Codable {
    let bookingNo, bookingDate: String
    let bookingFrom, bookingTo: String
    let primaryGuest, contactNo, emailID, gender: String
    let age, bookingID: Int
    let packagedetails: [Packagedetail]
    let packageguest: [Packageguest]
    let amountdetails: [AmountDetail]
    let adultCount, childCount: Int
    let tripStatus, tripMessage, imageUrl: String

    enum CodingKeys: String, CodingKey {
        case bookingNo = "booking_no"
        case bookingDate = "booking_date"
        case bookingFrom = "booking_from"
        case bookingTo = "booking_to"
        case primaryGuest = "primary_guest"
        case contactNo = "contact_no"
        case emailID = "email_id"
        case gender, age
        case bookingID = "bookingId"
        case packagedetails, packageguest, amountdetails, adultCount, childCount, tripStatus, tripMessage, imageUrl
        
    }
}

// MARK: - Packagedetail
struct Packagedetail: Codable {
    let packageID: Int
    let packageCode, packageName: String
    let countryID: Int
    let shortDescription: String
    let policies: String
    let duration: String
    let amount, count, costPerPerson, status: Int

    enum CodingKeys: String, CodingKey {
        case packageID = "packageId"
        case packageCode = "package_code"
        case packageName = "package_name"
        case countryID = "country_id"
        case shortDescription = "short_description"
        case policies
        case duration, amount, count, costPerPerson, status
    }
}

// MARK: - Packageguest
struct Packageguest: Codable {
    let guestName, contactNo, email, age: String
    let gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender
        case bookingID = "bookingId"
        case isPrimary
    }
}
