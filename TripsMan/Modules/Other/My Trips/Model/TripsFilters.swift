//
//  TripsFilters.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/05/23.
//

import Foundation

struct TripsFilters: Codable {
    var moduleCode: String? = nil
    var searchText: String? = nil
    var bookingStatus: BookingStatus? = nil
    var sortBy: Sortby? = nil
    
}

struct BookingStatus: Codable {
    var id: Int
    var status: String
}
