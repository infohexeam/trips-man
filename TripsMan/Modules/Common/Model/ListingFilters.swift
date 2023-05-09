//
//  ListingFilters.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/12/22.
//

import Foundation

struct HotelListingFilters: Codable {
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

struct PackageFilters: Codable {
    var country: Country? = nil
    var startDate: Date? = nil
    var adult: Int? = nil
    var child: Int? = nil
    var rate: Rate? = nil
    var filters: [String: [Int]]? = nil
    var sort: Sortby? = nil
    var packageDetails: PackageDetails? = nil
}


struct ActivityFilters: Codable {
    var country: Country? = nil
    var activityDate: Date? = nil
    var rate: Rate? = nil
    var filters: [String: [Int]]? = nil
    var sort: Sortby? = nil
    var memberCount: Int = 1
    var activityDetails: ActivityDetails? = nil
}

struct MeetupFilters: Codable {
    var country: Country? = nil
    var city: String? = nil
    var meetupDate: Date? = nil
    var rate: Rate? = nil
    var filters: [String: [Int]]? = nil
    var sort: Sortby? = nil
    var meetupDetails: MeetupDetails? = nil
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


