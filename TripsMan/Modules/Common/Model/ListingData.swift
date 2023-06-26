//
//  ListingData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 14/03/23.
//

import Foundation

struct ListingData: Codable {
    var type: ListType
    var id: Int
    var listImage: String?
    var placeHolderImage: String
    var isSponsored: Int
    var starRatingText: String?
    var userRating: UserRating?
    var listName: String
    var secondText: String
    var desc: String?
    var actualPrice: Double
    var offerPrice: Double
    var taxLabelText: String
}

struct UserRating: Codable {
    var ratingCount: Int
    var rating: String
    var ratingText: String
}
