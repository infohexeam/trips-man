//
//  MeetupTripDetails.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 21/06/23.
//

import Foundation

// MARK: - MeetupTripDetailsData
struct MeetupTripDetailsData: Codable {
    let data: MeetupTripDetails
    let status: Int
    let message: String
}

// MARK: - DataClass
struct MeetupTripDetails: Codable {
    let bookingNo, bookingDate: String
    let totalGuest: Int
    let bookingID, meetupID: Int
    let adultCount, tripStatusValue: Int
    let tripStatus, tripMessage: String
    let meetupGuests: [MeetupGuest]
    let meetupDetails: Meetupdetails
    let amountDetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingNo, bookingDate
        case totalGuest
        case bookingID = "bookingId"
        case meetupID = "meetupId"
        case adultCount, tripStatusValue, tripStatus, tripMessage, meetupGuests, meetupDetails, amountDetails
    }
}

// MARK: - Meetupdetails
struct Meetupdetails: Codable {
    let meetupID: Int
    let meetupName, countryID: String
    let meetupDate: String
    let countryName: String
    let shortDescription, termsandConditions: String
    let costPerPerson, status: Int

    enum CodingKeys: String, CodingKey {
        case meetupID = "meetupId"
        case meetupName
        case countryID = "countryId"
        case countryName
        case shortDescription = "short_description"
        case termsandConditions, costPerPerson, status, meetupDate
    }
}

// MARK: - MeetupGuest
struct Meetupguest: Codable {
    let guestName, contactNo: String
    let email: String?
    let age, gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender
        case bookingID = "bookingId"
        case isPrimary
    }
}
