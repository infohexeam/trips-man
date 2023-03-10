//
//  BookingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 31/01/23.
//

import Foundation

// MARK: - BookingData
struct CreateBookingData: Codable {
    let data: CreateBooking
    let status: Int
    let message: String
}

// MARK: - CreateBooking
struct CreateBooking: Codable {
    let bookingDate: String
    let bookingFrom, bookingTo: String
    let totalGuest: Int
    let primaryGuest, contactNo, emailID, gender: String
    let age, bookingID: Int
    let imageUrl: String?
    let roomDetails: [RoomDetail]
    let hotelDetails: HotelDetail
    let hotelGuests: [HotelGuest]
    let amountDetails: [AmountDetail]

    enum CodingKeys: String, CodingKey {
        case bookingDate, bookingFrom, bookingTo
        case totalGuest, primaryGuest, contactNo, imageUrl
        case emailID = "emailId"
        case gender, age
        case bookingID = "bookingId"
        case  roomDetails, hotelDetails, hotelGuests, amountDetails
    }
}

// MARK: - AmountDetail
struct AmountDetail: Codable {
    let amount: Int
    let label: String
    let isTotalAmount: Int
}

// MARK: - HotelDetail
struct HotelDetail: Codable {
    let hotelID: Int
    let hotelName, address: String
    
    enum CodingKeys: String, CodingKey {
        case hotelID = "hotelId"
        case hotelName, address
    }
}

// MARK: - HotelGuest
struct HotelGuest: Codable {
    let guestName, contactNo, email, age: String
    let gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender, isPrimary
        case bookingID = "bookingId"
    }
}

// MARK: - RoomDetail
struct RoomDetail: Codable {
    let roomID, hotelID: Int
    let roomType: String
    
    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case hotelID = "hotelId"
        case roomType
    }
}
