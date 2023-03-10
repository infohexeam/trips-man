//
//  LoginData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/10/22.
//

import Foundation

struct LoginData: Codable {
    let status: Int
    let message: String
    let userid: String?
    let usertype: Int?
    let username: String?
    let fullName: String?
    let token: String?
    
}


struct RegisterData: Codable {
    let status: Int
    let message: String
}
