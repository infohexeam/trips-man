//
//  CountryData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 04/01/23.
//

import Foundation

// MARK: - CountryData
struct CountryData: Codable {
    let data: [Country]
    let status: Int
    let message: String
}

// MARK: - Datum
struct Country: Codable {
    let countryID: Int
    let name, code: String
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case countryID = "countryId"
        case name, code, icon
    }
}
