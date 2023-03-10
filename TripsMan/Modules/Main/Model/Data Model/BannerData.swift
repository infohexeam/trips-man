//
//  BannerData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/01/23.
//

import Foundation

// MARK: - BannerData
struct BannerData: Codable {
    let data: [Banners]
    let status: Int
    let message: String
}

// MARK: - Datum
struct Banners: Codable {
    let id: Int
    let url: String
}
