//
//  PackageDetailsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/03/23.
//

import Foundation

// MARK: - PackageDetailsData
struct PackageDetailsData: Codable {
    let data: PackageDetails
    let status: Int
    let message: String
}

// MARK: - PackageDetails
struct PackageDetails: Codable {
    let packageID, holidayID: Int
    let packageCode, packageName: String
    let countryID: Int
    let shortDescription, policies, duration: String
    let amount, count: Int
    let status, vendorID: Int
    let countryName: String
    let packageType, isSponsored, ratingCount, durationDays: Int
    let userRating: Int
    let offerPrice, costPerPerson, serviceCharge: Double
    let holidayVendor: HolidayVendor
    let holidayItinerary: [HolidayItinerary]
    let holidayImage: [HolidayImage]

    enum CodingKeys: String, CodingKey {
        case packageID = "packageId"
        case holidayID = "holiday_id"
        case packageCode, packageName
        case countryID = "countryId"
        case shortDescription = "short_description"
        case policies, duration, amount, count
        case costPerPerson = "cost_per_person"
        case status
        case vendorID = "vendorId"
        case countryName, serviceCharge, packageType, isSponsored, ratingCount, userRating, offerPrice, holidayVendor, holidayItinerary, holidayImage, durationDays
    }
}


// MARK: - HolidayItinerary
struct HolidayItinerary: Codable {
    let id, packageID: Int
    let itineryName: String
    let itineryDescription: String?
    let image: String
    let day: String

    enum CodingKeys: String, CodingKey {
        case id
        case packageID = "package_id"
        case itineryName = "itinery_name"
        case itineryDescription = "itinery_description"
        case image, day
    }
}

// MARK: - HolidayVendor
struct HolidayVendor: Codable {
    let holidayID: Int
    let vendorCode, vendorName, vendorAddress, vendorDescription: String
    let vendorStatus: Int
    let vendorMobile, vendorEmail: String
    let serviceChargeType: String
    let serviceChargeValue: Int

    enum CodingKeys: String, CodingKey {
        case holidayID = "holiday_id"
        case vendorCode, vendorName, vendorAddress, vendorDescription, vendorStatus, vendorMobile, vendorEmail, serviceChargeType, serviceChargeValue
    }
}
