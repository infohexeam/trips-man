//
//  HotelDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/01/23.
//

import Foundation

import Foundation

// MARK: - HotelDetailsData
struct HotelDetailsData: Codable {
    let data: HotelDetails
    let status: Int
    let message: String
}

// MARK: - HotelDetails
struct HotelDetails: Codable {
    let hotelID: Int
    let hotelName, description, address, latitude: String
    let longitude, email, phone, shortDescription: String
    let propertyRules, propertyType, starRating, termsAndCondition: String
    let userRatingCount, status: Int
    let hotelFacilities: [HotelFacility]
    let hotelImages: [HotelImage]
    let hotelRooms: [HotelRoom]
    let hotelReviews: [HotelReview]
    let userRating: Double
    let featuredImage: String?
    let hotelStar: Int
    let hotelType: String

    enum CodingKeys: String, CodingKey {
        case hotelID = "hotelId"
        case hotelName, description, address, latitude, longitude, email, phone, shortDescription, propertyRules, propertyType, starRating, termsAndCondition, userRating, userRatingCount, status, featuredImage, hotelType, hotelStar
        case hotelFacilities = "hotel_Facilities"
        case hotelImages = "hotel_Images"
        case hotelRooms = "hotel_Rooms"
        case hotelReviews = "hotel_Reviews"
    }
}

// MARK: - HotelFacility
struct HotelFacility: Codable {
    let facilityName: String
    let facilityICon: String
    let facilityStatus, facilityID, hotelID, id: Int

    enum CodingKeys: String, CodingKey {
        case facilityName, facilityICon, facilityStatus, facilityID
        case hotelID = "hotelId"
        case id
    }
}

// MARK: - HotelImage
struct HotelImage: Codable {
    let id: Int
    let imageURL: String?
    let hotelID, status: Int

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "imageUrl"
        case hotelID = "hotelId"
        case status
    }
}

// MARK: - HotelReview
struct HotelReview: Codable {
    let reviewID, hotelID, customerID: Int
    let customerName, customerCode, hotelReview, reviewDate: String
    let customerImage, reviewTitle: String?
    let hotelRating: Double?

    enum CodingKeys: String, CodingKey {
        case reviewID = "reviewId"
        case hotelID = "hotelId"
        case customerID = "customerId"
        case customerName, customerCode, hotelRating, hotelReview, customerImage, reviewTitle, reviewDate
    }
}

// MARK: - HotelRoom
struct HotelRoom: Codable {
    let roomID, hotelID: Int
    let roomCode, roomType, roomDescription: String
    let actualPrice, offerPrice, serviceChargeValue: Double
    let roomFacilities: [RoomFacility]
    let roomImages: [RoomImage]?
    let isSoldOut: Int

    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case hotelID = "hotelId"
        case roomCode, roomType, roomDescription, actualPrice, offerPrice, serviceChargeValue, roomFacilities, roomImages, isSoldOut
    }
}

// MARK: - RoomFacility
struct RoomFacility: Codable {
    let roomFacilityID, roomID: Int
    let roomFacilityName: String
    let roomFacilityICon: String

    enum CodingKeys: String, CodingKey {
        case roomFacilityID
        case roomID = "roomId"
        case roomFacilityName, roomFacilityICon
    }
}

// MARK: - RoomImage
struct RoomImage: Codable {
    let id, roomID: Int
    let roomImage: String?
    let status, isFeatured: Int

    enum CodingKeys: String, CodingKey {
        case id
        case roomID = "roomId"
        case roomImage, status, isFeatured
    }
}
