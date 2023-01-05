//
//  ListingFilters.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/12/22.
//

import Foundation

struct ListingFilters: Codable {
    var location: String? = nil
    var checkin: Date? = nil
    var checkout: Date? = nil
    var room: Int? = nil
    var adult: Int? = nil
    var child: Int? = nil
}

