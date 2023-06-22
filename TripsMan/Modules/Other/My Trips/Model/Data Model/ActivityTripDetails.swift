//
//  ActivityTripDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/06/23.
//

import Foundation

// MARK: - ActivityTripDetailsData
struct ActivityTripDetailsData: Codable {
    let totalRecords: Int
    let data: ActivityTripDetails
    let status: Int
    let message: String
}

// MARK: - ActivityTripDetails
struct ActivityTripDetails: Codable {
    let bookingNo: String
    let bookingDate: String
    let bookingFrom: String
    let totalGuest: Int
    let bookingID, activityID: Int
    let tripStatusValue: Int
    let tripStatus, tripMessage: String
    let activitydetails: [Activitydetail]
    let activityguest: [Activityguest]
    let amountdetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingNo = "booking_no"
        case bookingDate = "booking_date"
        case bookingFrom = "booking_from"
        case totalGuest = "total_guest"
        case bookingID = "bookingId"
        case activityID = "activityId"
        case tripStatusValue, tripStatus, tripMessage, activitydetails, activityguest, amountdetails
    }
}

// MARK: - Activitydetail
struct Activitydetail: Codable {
    let activityID: Int
    let activityName, countryID: String
    let countryName: String
    let shortDescription, activityImage: String
    let overview: String

    enum CodingKeys: String, CodingKey {
        case activityID = "activityId"
        case activityName
        case countryID = "countryId"
        case countryName
        case shortDescription = "short_description"
        case overview, activityImage
    }
}

// MARK: - Activityguest
struct Activityguest: Codable {
    let id: Int
    let guestName, contactNo, emailID, age: String
    let gender: String
    let bookingID, status: Int

    enum CodingKeys: String, CodingKey {
        case id, guestName, contactNo
        case emailID = "emailId"
        case age, gender
        case bookingID = "bookingId"
        case status
    }
}
