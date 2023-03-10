//
//  ProfileData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 31/10/22.
//

import Foundation

struct ProfileData: Codable {
    let data: Profile
    let status: Int
    let message: String
}

// MARK: - Profile
struct Profile: Codable {
    let id: Int
    let userId, customerName, mobile, email: String
    let customerCode, address1, address2, city, state, country, countryId, pincode, gender, dob, photo: String?
}


//MARK: - BasicResponse
struct BasicResponse: Codable {
    let status: Int
    let message: String
}
