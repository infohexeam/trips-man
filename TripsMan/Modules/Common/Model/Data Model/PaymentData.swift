//
//  PaymentData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/06/23.
//

import Foundation

// MARK: - PaymentData
struct PaymentData: Codable {
    let data: String
    let status: Int
    let message: String
}

