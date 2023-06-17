//
//  ActivityBookingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/04/23.
//

import Foundation

// MARK: - ActivityBookingData
struct ActivityBookingData: Codable {
    let totalRecords: Int
    let data: ActivityBooking
    let status: Int
    let message: String
}

// MARK: - ActivityBooking
struct ActivityBooking: Codable {
    let bookingDate: String
    let bookingFrom: String
    let activityName, location: String
    let bookingId, adultCount: Int
    let activityGuests: [ActivityGuest]
    let amountDetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingDate, bookingFrom, bookingId
        case activityName, adultCount, activityGuests, amountDetails, location
    }
}

// MARK: - ActivityGuest
struct ActivityGuest: Codable {
    let guestName, contactNo, email, age: String
    let gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender
        case bookingID = "bookingId"
        case isPrimary
    }
}
