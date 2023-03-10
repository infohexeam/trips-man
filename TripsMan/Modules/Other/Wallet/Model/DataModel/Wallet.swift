//
//  Wallet.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 08/02/23.
//

import Foundation

// MARK: - WalletData
struct WalletData: Codable {
    let data: Wallet
    let status: Int
    let message: String
}

// MARK: - Datum
struct Wallet: Codable {
    let totalPoints: Double
    let detail: [Detail]
}

// MARK: - Detail
struct Detail: Codable {
    let points: Double
    let date: String
    let description, currencyValue: String?
}
