//
//  RewardPointsData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 01/06/23.
//

import Foundation

// MARK: - RewardPointsData
struct RewardPointsData: Codable {
    let data: [Amount]
    let status: Int
    let message: String
}

