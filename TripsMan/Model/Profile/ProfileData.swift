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
    let customerCode, userId, customerName, mobile, email: String
    let address1, address2, city, state, country, pincode, gender, dob, photo: String?
}
