//
//  SessionManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/12/22.
//

import Foundation
import UIKit

struct SessionKeys {
    static let loginData = "loginData"
    static let selectedCountry = "selectedCountry"
    static let currency = "currency"
}

class SessionManager {
    static let shared = SessionManager()
    let defaults = UserDefaults.standard
    
    func saveLoginDetails(_ data: LoginData) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            defaults.set(encoded, forKey: SessionKeys.loginData)
        }
    }
    
    func getLoginDetails() -> LoginData? {
        if let loginData = defaults.object(forKey: SessionKeys.loginData) as? Data {
            let decoder = JSONDecoder()
            if let loginDetails = try? decoder.decode(LoginData.self, from: loginData) {
                return loginDetails
            }
        }
        return nil
    }
    
    func logout() {
        let keys = defaults.dictionaryRepresentation()
        for each in keys {
            defaults.removeObject(forKey: each.key)
        }

    }
    
    
    func getLanguage() -> String {
        //EN,AR
        return "EN"
    }
    
    func setCountry(_ country: CountrySelection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(country) {
            defaults.set(encoded, forKey: SessionKeys.selectedCountry)
        }
        
        
    }
    
    func getCountry() -> String {
        //IND.UAE,OTH
        if let countryData = defaults.object(forKey: SessionKeys.selectedCountry) as? Data {
            let decoder = JSONDecoder()
            if let country = try? decoder.decode(CountrySelection.self, from: countryData) {
                return country.countryCode
            }
        }
        return "IND"
    }
    
    func getCurrency() -> String {
        //INR,AED,USD
        if let countryData = defaults.object(forKey: SessionKeys.selectedCountry) as? Data {
            let decoder = JSONDecoder()
            if let country = try? decoder.decode(CountrySelection.self, from: countryData) {
                return country.currency
            }
        }
        return "INR"
    }
}
