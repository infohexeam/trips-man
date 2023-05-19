//
//  SearchData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/05/23.
//

import Foundation

struct SearchData: Codable {
    let data: Search
    let status: Int
    let message: String
}

struct Search: Codable {
    let hotel: [HotelSearch]?
    let holiday: [HolidaySearch]?
    let activity: [ActivitySearch]?
    let meetup: [MeetupSearch]?
}


struct HotelSearch: Codable {
    let hotelID: Int
    let hotelName, hotelType: String
    let hotelCity, hotelState: String?
    
    enum CodingKeys: String, CodingKey {
        case hotelID = "hotelId"
        case hotelName, hotelType, hotelCity, hotelState
    }
}

struct HolidaySearch: Codable {
    let packageID: Int
    let packageName, countryName: String
    
    enum CodingKeys: String, CodingKey {
        case packageID = "packageId"
        case packageName, countryName
    }
}

struct ActivitySearch: Codable {
    let activityID: Int
    let activityName, activityLocation: String
    
    enum CodingKeys: String, CodingKey {
        case activityID = "activityId"
        case activityName, activityLocation
    }
}

struct MeetupSearch: Codable {
    let meetupID: Int
    let meetupName: String
    
    enum CodingKeys: String, CodingKey {
        case meetupID = "meetupId"
        case meetupName
    }
}

