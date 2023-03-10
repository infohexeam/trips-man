//
//  MyTrips.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 02/02/23.
//

import Foundation

// MARK: - MyTripsData
struct MyTripsData: Codable {
    let totalRecords: Int
    let data: [MyTrips]
    let status: Int
    let message: String
}

// MARK: - MyTrips
struct MyTrips: Codable {
    let bookingID, bookedDate, checkInDate, checkOutDate: String
    let totalAmount: Int
    let customerName, hotelName: String
    let totalGuest: Int
    let primaryGuest: String
    let contactNo: String
    let gender: String
    let age, hotelID, isCancelled: Int
    let imageURL: String?
    let roomCount, tripStatusValue: Int
    let tripStatus: String?

    enum CodingKeys: String, CodingKey {
        case bookingID = "bookingId"
        case bookedDate, totalAmount, checkInDate, checkOutDate, hotelName, tripStatusValue
        case customerName, totalGuest, primaryGuest, contactNo, gender, age
        case hotelID = "hotelId"
        case isCancelled, tripStatus
        case imageURL = "imageUrl"
        case roomCount
    }
}
