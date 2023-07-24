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
    static let selectedLanguage = "selectedLanguage"
    static let currency = "currency"
    static let fcmToken = "fcmToken"
    static let appleLanguage = "AppleLanguage"  //Default Key by apple for language
    static let appleSignInDetails = "appleSignInDetails"
}

struct AppleSigninUserDetails: Codable {
    var userId: String
    var fullName: String
    var email: String
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
            if each.key != SessionKeys.fcmToken && each.key != SessionKeys.appleLanguage {
                defaults.removeObject(forKey: each.key)
            }
        }
    }
    
    func setLanguage(_ language: LanguageSelection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(language) {
            defaults.set(encoded, forKey: SessionKeys.selectedLanguage)
            defaults.set(language.code, forKey: SessionKeys.appleLanguage)
            
            if language.code == "ar" {
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
            } else {
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
            }
            defaults.synchronize()
            
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
            let mainRootController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            window.rootViewController = mainRootController
            window.makeKeyAndVisible()
            UIView.transition(with: window, duration: 0.55001, options: .transitionFlipFromLeft, animations: { () -> Void in
            }) { (finished) -> Void in
            }
        }
    }
    
    
    func getLanguage() -> LanguageSelection {
        //EN,AR
        if let languageData = defaults.object(forKey: SessionKeys.selectedLanguage) as? Data {
            let decoder = JSONDecoder()
            if let language = try? decoder.decode(LanguageSelection.self, from: languageData) {
                return language
            }
        }
        return K.languages[0]
    }
    
    func setCountry(_ country: CountrySelection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(country) {
            defaults.set(encoded, forKey: SessionKeys.selectedCountry)
        }
    }
    
    func getCountry() -> CountrySelection {
        //IND.UAE
        if let countryData = defaults.object(forKey: SessionKeys.selectedCountry) as? Data {
            let decoder = JSONDecoder()
            if let country = try? decoder.decode(CountrySelection.self, from: countryData) {
                return country
            }
        }
        return K.countries[0]
    }
    
    func getCurrency() -> String {
        //INR,AED
        if let countryData = defaults.object(forKey: SessionKeys.selectedCountry) as? Data {
            let decoder = JSONDecoder()
            if let country = try? decoder.decode(CountrySelection.self, from: countryData) {
                return country.currency
            }
        }
        return "INR"
    }
    
    func saveFcmToken(_ token: String) {
        defaults.set(token, forKey: SessionKeys.fcmToken)
    }
    
    func getFcmToken() -> String? {
        if let token = defaults.string(forKey: SessionKeys.fcmToken) {
            return token
        }
        return nil
    }
    
    
    //Sign-in with apple
    //Save user details in cache (to use in case of error in initial attempt to register) and remove it upon on successful registration.
    
    func saveAppleSigninDetails(_ details: AppleSigninUserDetails) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(details) {
            defaults.set(encoded, forKey: SessionKeys.appleSignInDetails)
        }
    }
    
    func getAppleSigninDetails() -> AppleSigninUserDetails? {
        if let signinData = defaults.object(forKey: SessionKeys.appleSignInDetails) as? Data {
            let decoder = JSONDecoder()
            if let loginDetails = try? decoder.decode(AppleSigninUserDetails.self, from: signinData) {
                return loginDetails
            }
        }
        return nil
    }
    
    func removeAppleSigninDetails() {
        defaults.removeObject(forKey: SessionKeys.appleSignInDetails)
    }
}
