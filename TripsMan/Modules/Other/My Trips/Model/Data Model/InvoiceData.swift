//
//  InvoiceData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/06/23.
//

import Foundation

// MARK: - InvoiceData
struct InvoiceData: Codable {
    let data: InvoiceUrl
    let status: Int
    let message: String
}

// MARK: - DataClass
struct InvoiceUrl: Codable {
    let url: String
}
