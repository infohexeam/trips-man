//
//  CheckoutData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 31/05/23.
//

import Foundation

// MARK: - CheckoutData
struct CheckoutData: Codable {
    let data: Checkout
    let status: Int
    let message: String
}

// MARK: - Checkout
struct Checkout: Codable {
    let customerPoints, maximumRedeamAmount, redeamPercentage, redeamablePoints, redeamableAmount: Double
    let amounts: [Amount]
}

// MARK: - Amount
struct Amount: Codable {
    let amount: Double
    let label: String
    let isTotalAmount: Int
}


// MARK: - ConfirmBookingData
struct ConfirmBookingData: Codable {
    let data: ConfirmBooking
    let status: Int
    let message: String
}

// MARK: - ConfirmBooking
struct ConfirmBooking: Codable {
    let bookingNo, module: String
}
