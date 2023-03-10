//
//  ListingFilters.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/12/22.
//

import Foundation

struct ListingFilters: Codable {
    var location: Location? = nil
    var checkin: Date? = nil
    var checkout: Date? = nil
    var roomCount: Int? = nil
    var adult: Int? = nil
    var child: Int? = nil
    var rate: Rate? = nil
    var filters: [String: [Int]]? = nil
    var sort: Sortby? = nil
    var tripType: TripType? = nil
    var roomDetails: Room? = nil
}

struct Rate: Codable {
    var from: Int
    var to: Int
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var name: String
}

struct Room: Codable {
    var hotelID: Int
    var roomID: Int
}


