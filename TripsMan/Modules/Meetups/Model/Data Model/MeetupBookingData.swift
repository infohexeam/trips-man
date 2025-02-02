//
//  MeetupBookingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 09/05/23.
//

import Foundation

// MARK: - MeetupBookingData
struct MeetupBookingData: Codable {
    let data: MeetupBooking
    let status: Int
    let message: String
}

// MARK: - MeetupBooking
struct MeetupBooking: Codable {
    let bookingDate: String
    let meetupName, address: String
    let meetupDate: String
    let bookingId, adultCount, childCount: Int
    let meetupGuests: [MeetupGuest]
    let amountDetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingDate, meetupDate, bookingId, meetupName, address
        case adultCount, childCount, meetupGuests, amountDetails
    }
}

// MARK: - MeetupGuest
struct MeetupGuest: Codable {
    let guestName, contactNo, email, age: String
    let gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender
        case bookingID = "bookingId"
        case isPrimary
    }
}
