//
//  RoomDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 04/07/23.
//

import Foundation

// MARK: - RoomDetailsData
struct RoomDetailsData: Codable {
    let data: [RoomDetails]
    let status: Int
    let message: String
}

// MARK: - RoomDetails
struct RoomDetails: Codable {
    let roomID, hotelID: Int
    let hotelName: String
    let hotelImage: String
    let roomCode, roomType, roomDescription: String
    let roomPrice, offerPrice, serviceChargeValue, roomStatus: Int
    let isDeleted: Int
    let roomFacilities: [RoomFacility]
    let roomHouseRules: [RoomHouseRule]
    let roomImage: [RoomImage]
    let popularAmenities: [PopularAmenity]
    let roomCount, adultCount, childCount, availableRoomCount: Int

    enum CodingKeys: String, CodingKey {
        case roomID = "roomId"
        case hotelID = "hotelId"
        case hotelName, hotelImage, roomCode, roomType, roomDescription, roomPrice, offerPrice, serviceChargeValue, roomStatus, isDeleted, roomFacilities, roomHouseRules, roomImage, popularAmenities, roomCount, adultCount, childCount, availableRoomCount
    }
}

// MARK: - PopularAmenity
struct PopularAmenity: Codable {
    let roomPopularAmenityName: String
    let roomPopularAmenityICon: String?
    let roomPopularAmenityStatus, roomPopularAmenityID, roomID, id: Int
    let status: Int

    enum CodingKeys: String, CodingKey {
        case roomPopularAmenityName
        case roomPopularAmenityICon, roomPopularAmenityStatus, roomPopularAmenityID
        case roomID = "roomId"
        case id, status
    }
}

// MARK: - RoomHouseRule
struct RoomHouseRule: Codable {
    let houseRulesName, aRHouseRulesName: String
    let houseRulesID, roomID, id, status: Int

    enum CodingKeys: String, CodingKey {
        case houseRulesName
        case aRHouseRulesName = "aR_HouseRulesName"
        case houseRulesID = "houseRulesId"
        case roomID = "roomId"
        case id, status
    }
}

