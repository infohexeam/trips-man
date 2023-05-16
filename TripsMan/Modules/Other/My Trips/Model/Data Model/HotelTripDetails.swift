//
//  TripDetails.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 02/02/23.
//

import Foundation

// MARK: - TripDetailsData
struct HotelTripDetailsData: Codable {
    let totalRecords: Int
    let data: HotelTripDetails
    let status: Int
    let message: String
}

// MARK: - TripDetails
struct HotelTripDetails: Codable {
    let bookingDate: String
    let totalAmount: Int
    let bookingFrom, bookingTo: String
    let totalCharge, tax, serviceCharge, discount: Int
    let totalPrice, totalGuest: Int
    let bookingID: Int
    let reviewId: Int?
    let rating: Double?
    let review, reviewTitle, reviewDate: String?
    let hotelID, roomID, isCancelled: Int
    let imageURL, bookingNo: String?
    let tripStatusValue: Int
    let tripStatus, hotelName: String
    let roomCount, adultCount, childCount: Int
    let tripMessage: String
    let roomDetails: [RoomDetail]
    let hotelDetails: TripHotelDetails
    let hotelGuests: [HotelGuest]
    let amountDetails: [AmountDetail]
    
    
    enum CodingKeys: String, CodingKey {
        case bookingNo, bookingDate, totalAmount, bookingFrom, bookingTo, reviewId, review, rating, reviewTitle
        case totalCharge, tax, serviceCharge, discount, totalPrice, totalGuest, reviewDate
        case bookingID = "bookingId"
//        case rating, review
        case hotelID = "hotelId"
        case roomID = "roomId"
        case isCancelled
        case imageURL = "imageUrl"
        case tripStatusValue, tripStatus, hotelName, roomCount, adultCount, childCount, tripMessage, roomDetails, hotelDetails, hotelGuests, amountDetails
    }
}


struct TripHotelDetails: Codable {
    let hotelId: Int
    let hotelName, address, latitude: String
    let checkInTime, checkOutTime: String?
}
