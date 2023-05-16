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
    let module: String
    let bookingID: Int
    let bookingNo: String?
    let bookedDate: String
    let totalAmount: Int
    let checkInDate, checkOutDate: String
    let checkInTime, checkOutTime: String?
    let customerCode, customerID: String
    let customerName: String
    let totalGuest: Int
    let primaryGuest, contactNo: String
    let gender: String
    let age, id, isCancelled, tripStatusValue: Int
    let tripStatus, name: String
    let imageURL: String?
    let adultCount, childCount: Int
    let tripMessage: String?
    let bookingMessage: String
    let bookingStatus: String
    let roomCount: Int
    let place: String?

    enum CodingKeys: String, CodingKey {
        case module
        case bookingID = "bookingId"
        case bookingNo, bookedDate, totalAmount, checkInDate, checkOutDate, checkInTime, checkOutTime, customerCode
        case customerID = "customerId"
        case customerName, totalGuest, primaryGuest, contactNo, gender, age, id, isCancelled, tripStatusValue, tripStatus, name
        case imageURL = "imageUrl"
        case adultCount, childCount, tripMessage, bookingMessage, bookingStatus, roomCount, place
    }
}
