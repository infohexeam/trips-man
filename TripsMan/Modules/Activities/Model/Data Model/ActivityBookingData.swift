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
    let bookingNo, bookingDate: String
    let totalAmount: Int
    let bookingFrom, bookingTo, customerCode, customerID: String
    let customerName: String
    let totalPrice, totalGuest: Int
    let primaryGuest, contactNo, emailID, gender: String
    let age, bookingID, activityID, isCancelled: Int
    let imageURL: String
    let activityName: String
    let adultCount, childCount: Int
    let activityGuests: [ActivityGuest]
    let amountDetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingNo, bookingDate, totalAmount, bookingFrom, bookingTo, customerCode
        case customerID = "customerId"
        case customerName, totalPrice, totalGuest, primaryGuest, contactNo
        case emailID = "emailId"
        case gender, age
        case bookingID = "bookingId"
        case activityID = "activityId"
        case isCancelled
        case imageURL = "imageUrl"
        case activityName, adultCount, childCount, activityGuests, amountDetails
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
