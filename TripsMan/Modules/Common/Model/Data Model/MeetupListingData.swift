//
//  MeetupListingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/05/23.
//

import Foundation

// MARK: - MeetupListingData
struct MeetupListingData: Codable {
    let totalRecords: Int
    let data: [Meetup]
    let status: Int
    let message: String
}

// MARK: - Meetup
struct Meetup: Codable {
    let meetupID: Int
    let meetupName, address, meetupCode: String
    let countryID: Int
    let countryName, shortDescription, termsAndConditions, details: String
    let latitude, longitude, costPerPerson, meetupDate: String
    let meetupType, meetupStatus: String
    let meetupImages: [MeetupImage]

    enum CodingKeys: String, CodingKey {
        case meetupID = "meetupId"
        case meetupName, address, meetupCode
        case countryID = "countryId"
        case countryName, shortDescription, termsAndConditions, details, latitude, longitude, costPerPerson, meetupDate, meetupType, meetupStatus
        case meetupImages = "meetup_Images"
    }
}

// MARK: - MeetupImage
struct MeetupImage: Codable {
    let id: Int
    let imageURL: String
    let isFeatured, meetupID, status: Int

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "imageUrl"
        case isFeatured
        case meetupID = "meetupId"
        case status
    }
}


