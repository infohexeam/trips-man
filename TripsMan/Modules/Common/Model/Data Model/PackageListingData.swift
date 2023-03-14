//
//  PackageListingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 13/03/23.
//

import Foundation

// MARK: - PackageListingData
struct PackageListingData: Codable {
    let data: [HolidayPackage]
    let status: Int
    let message: String
}

// MARK: - HolidayPackage
struct HolidayPackage: Codable {
    let packageID, holidayID: Int
    let packageCode, packageName: String
    let countryID: Int
    let shortDescription, policies, duration: String
    let amount, offerPrice, costPerPerson, seviceCharge: Double
    let status, vendorID: Int
    let countryName: String
    let isSponsored: Int
    let holidayImage: [HolidayImage]

    enum CodingKeys: String, CodingKey {
        case packageID = "packageId"
        case holidayID = "holiday_id"
        case packageCode, packageName
        case countryID = "countryId"
        case shortDescription = "short_description"
        case policies, duration, amount, offerPrice
        case costPerPerson = "cost_per_person"
        case seviceCharge, status
        case vendorID = "vendorId"
        case countryName, isSponsored, holidayImage
    }
}

// MARK: - HolidayImage
struct HolidayImage: Codable {
    let id, packageID: Int
    let imageURL: String?
    let isFeatured: Int

    enum CodingKeys: String, CodingKey {
        case id
        case packageID = "package_id"
        case imageURL = "image_url"
        case isFeatured = "is_featured"
    }
}

