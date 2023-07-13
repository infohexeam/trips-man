//
//  PackageBookingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/04/23.
//

import Foundation


// MARK: - Welcome
struct PackageBookingData: Codable {
    let data: PackageBooking
    let status: Int
    let message: String
}

// MARK: - PackageBooking
struct PackageBooking: Codable {
    let bookingDate: String
    let totalAmount: Double
    let bookingFrom, bookingTo, customerCode, customerID: String
    let customerName: String
    let totalCharge, tax, serviceCharge, discount: Double
    let totalPrice: Double
    let totalGuest: Int
    let primaryGuest, contactNo, emailID, gender: String
    let age, bookingID, packageID, roomID: Int
    let imageURL: String?
    let packageName: String?
    let adultCount, childCount: Int
    let packageDetails: SummaryPackageDetails?
    let holidayGuests: [HolidayGuest]
    let amountDetails: [AmountDetail]
    let vendorDetails: VendorDetails

    enum CodingKeys: String, CodingKey {
        case bookingDate, totalAmount, bookingFrom, bookingTo, customerCode
        case customerID = "customerId"
        case customerName, totalCharge, tax, serviceCharge, discount, totalPrice, totalGuest, primaryGuest, contactNo
        case emailID = "emailId"
        case gender, age
        case bookingID = "bookingId"
        case packageID = "packageId"
        case roomID = "roomId"
        case imageURL = "imageUrl"
        case packageName, adultCount, childCount, holidayGuests, amountDetails
        case packageDetails, vendorDetails
    }
}

//MARK: - SummaryPackageDetails
struct SummaryPackageDetails: Codable {
    let packageID: Int
    let packageName, duration: String
    let costPerPerson: Double
    let status, durationDays: Int
    let countryName: String

    enum CodingKeys: String, CodingKey {
        case packageID = "packageId"
        case packageName, duration
        case costPerPerson = "cost_per_person"
        case status
        case countryName, durationDays
    }
}


// MARK: - HolidayGuest
struct HolidayGuest: Codable {
    let guestName, contactNo, email, age: String
    let gender: String
    let bookingID, isPrimary: Int

    enum CodingKeys: String, CodingKey {
        case guestName, contactNo, email, age, gender
        case bookingID = "bookingId"
        case isPrimary
    }
}


struct VendorDetails: Codable {
    let holidayID: Int
    let vendorCode, vendorName, vendorAddress, vendorDescription: String
    let vendorStatus: Int
    let vendorMobile, vendorEmail: String
    let serviceChargeType: String
    let serviceChargeValue: Int
    let vendorImage: String?

    enum CodingKeys: String, CodingKey {
        case holidayID = "holiday_id"
        case vendorCode, vendorName, vendorAddress, vendorDescription, vendorStatus, vendorMobile, vendorEmail, serviceChargeType, serviceChargeValue, vendorImage
    }
}
