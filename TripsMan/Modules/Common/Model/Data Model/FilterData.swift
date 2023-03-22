//
//  FilterData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/01/23.
//

import Foundation

// MARK: - FilterData
struct FilterResp: Codable {
    let data: FilterData
    let status: Int
    let message: String
}

// MARK: - DataClass
struct FilterData: Codable {
    let filtes: [Filter]?
    let filters: [Filter]?
    let sortby: [Sortby]
    let tripTypes: [TripType]?
}

// MARK: - Filte
struct Filter: Codable {
    let title, type, filterKey: String
    let values: [FilterValue]
}


//MARK: - FilterValue
struct FilterValue: Codable {
    let name: String
    let id: Int
}

// MARK: - Sortby
struct Sortby: Codable {
    let name: String
    let id: Int
}

// MARK: - Sortby
struct TripType: Codable {
    let name: String
    let id: Int
}
