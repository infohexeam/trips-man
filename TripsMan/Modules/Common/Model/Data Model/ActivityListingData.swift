//
//  ActivityListingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/04/23.
//

import Foundation

// MARK: - ActivityListingData
struct ActivityListingData: Codable {
    let totalRecords: Int
    let data: [Activity]
    let status: Int
    let message: String
}

// MARK: - ActivityListingData
struct Activity: Codable {
    let activityID, isSponsored: Int
    let activityName, activityCode: String
    let activityLocation: String
    let costPerPerson, offerPrice: Double
    let serviceChargeValue: Double?
    let activityAmount, activityStatus: String
    let activityImages: [ActivityImage]
    let activityInclusion: [ActivityInclusion]

    enum CodingKeys: String, CodingKey {
        case activityID = "activityId"
        case isSponsored, activityName, activityCode
        case activityLocation, costPerPerson, offerPrice, serviceChargeValue, activityAmount, activityStatus
        case activityImages = "activity_Images"
        case activityInclusion
    }
}

// MARK: - ActivityImage
struct ActivityImage: Codable {
    let id: Int
    let imageURL: String
    let isFeatured, activityID, status: Int

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "imageUrl"
        case isFeatured
        case activityID = "activityId"
        case status
    }
}

// MARK: - ActivityInclusion
struct ActivityInclusion: Codable {
    let inclusionName: String
    let inclusionICon: String
    let inclusionStatus, inclusionID, activityID, status: Int

    enum CodingKeys: String, CodingKey {
        case inclusionName
        case inclusionICon, inclusionStatus
        case inclusionID = "inclusionId"
        case activityID = "activityId"
        case status
    }
}


