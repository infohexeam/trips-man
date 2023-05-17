////
////  HolidayTripDetails.swift
////  TripsMan
////
////  Created by Hexeam Software Solutions on 17/05/23.
////
//
//import Foundation
//
//// MARK: - HolidayTripDetailsData
//struct HolidayTripDetailsData: Codable {
//    let totalRecords: Int
//    let data: [HolidayTripDetails]
//    let status: Int
//    let message: String
//}
//
//// MARK: - HolidayTripDetails
//struct HolidayTripDetails: Codable {
//    let bookingNo, bookingDate: String
//    let bookingFrom, bookingTo: String
//    let primaryGuest, contactNo, emailID, gender: String
//    let age, datumBookingID: Int
//    let bookingID: Int
//    let packagedetails: [Packagedetail]
//
//    enum CodingKeys: String, CodingKey {
//        case bookingNo = "booking_no"
//        case bookingDate = "booking_date"
//        case totalAmount = "total_amount"
//        case bookingFrom = "booking_from"
//        case bookingTo = "booking_to"
//        case customerCode = "customer_code"
//        case customerName = "customer_name"
//        case customerID = "customerId"
//        case totalCharge = "total_charge"
//        case tax
//        case serviceCharge = "service_charge"
//        case discount
//        case totalPrice = "total_price"
//        case totalGuest = "total_guest"
//        case primaryGuest = "primary_guest"
//        case contactNo = "contact_no"
//        case emailID = "email_id"
//        case gender, age
//        case datumBookingID = "booking_id"
//        case rating, review
//        case bookingID = "bookingId"
//        case packageID = "packageId"
//        case isCancelled = "is_cancelled"
//        case packagedetails, packageguest
//    }
//}
//
//// MARK: - Packagedetail
//struct Packagedetail: Codable {
//    let packageID: Int
//    let packageCode, packageName: String
//    let countryID: Int
//    let shortDescription: String
//    let arShortDescription: JSONNull?
//    let policies: String
//    let arPolicies: JSONNull?
//    let duration: String
//    let amount, count, costPerPerson, status: Int
//
//    enum CodingKeys: String, CodingKey {
//        case packageID = "packageId"
//        case packageCode = "package_code"
//        case packageName = "package_name"
//        case countryID = "country_id"
//        case shortDescription = "short_description"
//        case arShortDescription = "ar_short_description"
//        case policies
//        case arPolicies = "ar_policies"
//        case duration, amount, count, costPerPerson, status
//    }
//}
