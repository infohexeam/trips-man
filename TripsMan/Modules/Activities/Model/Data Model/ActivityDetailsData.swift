//
//  ActivityDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/04/23.
//

import Foundation

// MARK: - ActivityDetailsData
struct ActivityDetailsData: Codable {
    let data: ActivityDetails
    let status: Int
    let message: String
}

// MARK: - ActivityDetails
struct ActivityDetails: Codable {
    let activityID: Int
    let activityName, activityCode: String
    let countryID: Int
    let contactPerson, contactName, shortDescription, contactNumber: String
    let contactEmail, overview, features, termsAndConditions: String
    let activityLocation, highlights, activityDuration: String
    let costPerPerson, offerPrice, serviceChargeValue: Double
    let activityAmount, activityStatus: String
    let isSponsored: Int
    let latitude, longitude: Double
    let activityImages: [ActivityImage]
    let activityType: [ActivityType]
    let activityInclusion: [ActivityInclusion]

    enum CodingKeys: String, CodingKey {
        case activityID = "activityId"
        case activityName, activityCode
        case countryID = "countryId"
        case contactPerson, contactName, shortDescription, contactNumber, contactEmail, overview, features, termsAndConditions, activityLocation, highlights, activityDuration, costPerPerson, offerPrice, serviceChargeValue, activityAmount, activityStatus, isSponsored, latitude, longitude
        case activityImages = "activity_Images"
        case activityType, activityInclusion
    }
}


// MARK: - ActivityType
struct ActivityType: Codable {
    let activityTypeName: String
    let activityTypeID, activityID, id, status: Int

    enum CodingKeys: String, CodingKey {
        case activityTypeName
        case activityTypeID = "activityTypeId"
        case activityID = "activityId"
        case id, status
    }
}
