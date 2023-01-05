//
//  ImageUploadData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 04/01/23.
//

import Foundation

// MARK: - ImageUploadData
struct ImageUploadData: Codable {
    let data: ImageData
    let status: Int
    let message: String
}

// MARK: - ImageData
struct ImageData: Codable {
    let url: String
    let savepath: String
}

