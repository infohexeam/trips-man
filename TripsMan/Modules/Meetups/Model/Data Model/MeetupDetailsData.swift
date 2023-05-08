//
//  MeetupDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 08/05/23.
//

import Foundation

// MARK: - MeetupDetailsData
struct MeetupDetailsData: Codable {
    let data: MeetupDetails
    let status: Int
    let message: String
}

// MARK: - MeetupDetails
struct MeetupDetails: Codable {
    let meetupID: Int
    let meetupName, address, meetupCode: String
    let countryID: Int
    let countryName, shortDescription, termsAndConditions, details: String
    let latitude, longitude: String
    let costPerPerson, offerAmount, serviceCharge: Double
    let meetupDate, meetupType, meetupStatus: String
    let meetupImages: [MeetupImage]

    enum CodingKeys: String, CodingKey {
        case meetupID = "meetupId"
        case meetupName, address, meetupCode
        case countryID = "countryId"
        case countryName, shortDescription, termsAndConditions, details, latitude, longitude, costPerPerson, offerAmount, serviceCharge, meetupDate, meetupType, meetupStatus
        case meetupImages = "meetup_Images"
    }
}

