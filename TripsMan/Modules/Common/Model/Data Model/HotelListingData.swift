//
//  HotelListingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/01/23.
//

import Foundation

// MARK: - HotelData
struct HotelData: Codable {
    let data: [Hotel]
    let status: Int
    let message: String
}

// MARK: - Hotel
struct Hotel: Codable {
    let hotelID: Int
    let hotelName, hotelAddress, hotelLatitude, hotelLongitude: String
    let hotelEmail, hotelMobile, shortDescription, description: String
    let propertyRules, termsAndCondition, serviceChargeType, hotelType: String
    let hotelStatus, isSponsored, userRatingCount: Int
    let offerPrice, actualPrice, userRating, serviceChargeValue: Double
    let imageUrl: String?
    let hotelStar: Int
    let hotelCity, hotelState: String?
    

    enum CodingKeys: String, CodingKey {
        case hotelID = "hotelId"
        case hotelName, hotelAddress, hotelLatitude, hotelLongitude, hotelEmail, hotelMobile, shortDescription, description, propertyRules, termsAndCondition, serviceChargeType, serviceChargeValue, hotelStatus, imageUrl, offerPrice, actualPrice, isSponsored, userRating, userRatingCount, hotelType, hotelStar, hotelCity, hotelState
    }
}
