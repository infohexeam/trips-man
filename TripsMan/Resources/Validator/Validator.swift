//
//  Validator.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 09/09/22.
//

import Foundation
import UIKit

struct EmailValidator {
    func validate(_ email: String) -> (Bool, String) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return (emailPred.evaluate(with: email), "Invalid email")
    }
}

struct UserNameValidator {
    func validate(_ userName: String) -> (Bool, String) {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let digitsCharacters = CharacterSet.decimalDigits

        
        var isValid = false
        if emailPred.evaluate(with: userName) {
            isValid = true
        } else if CharacterSet(charactersIn: userName).isSubset(of: digitsCharacters) && userName.count >= 10 {
            isValid = true
        }
        
        return (isValid, "Invalid email / mobile number".localized())
    }
}

struct PasswordValidator {
    func validate(_ password: String) -> (Bool, String) {
        
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let capitalPred = NSPredicate(format: "SELF MATCHES %@", capitalLetterRegEx)
        
        let smallLetterRegEx  = ".*[a-z]+.*"
        let smallPred = NSPredicate(format: "SELF MATCHES %@", smallLetterRegEx)
        
        let numberRegEx  = ".*[0-9]+.*"
        let numberPred = NSPredicate(format: "SELF MATCHES %@", numberRegEx)
        
        let specialCharacterRegEx = ".*[!&^%$#@()/]+.*"
        let specialPred = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegEx)
        
         
        var isValid = false
        if password.count >= 7 && capitalPred.evaluate(with: password) && smallPred.evaluate(with: password) && numberPred.evaluate(with: password) && specialPred.evaluate(with: password) {
            isValid = true
        }
        return (isValid, "Password should contain at least 1 lowercase letter, 1 uppercase letter, 1 special character, 1 number and a minimum length of 8 characters".localized())
    }
    
    func retypeValidate(_ password: String, _ retype: String) -> (Bool, String) {
        return (password == retype, "Password mismatch".localized())
    }
}

struct NameValidator {
    func validate(_ name: String) -> (Bool, String) {
        return (name.count >= 3, "Your name is too short".localized())
    }
}


struct MobileValidator {
    func validate(_ mobile: String) -> (Bool, String) {
        return (mobile.count >= 9, "Invalid mobile number".localized())
    }
}

struct OTPValidator {
    func validate(_ otp: String) -> (Bool, String) {
        return (otp.count >= 4, "Invalid otp".localized())
    }
}

struct AddressValidator {
    func validate(_ address: String) -> (Bool, String) {
        return (address.count >= 3, "Your address is too short".localized())
    }
}

struct CityValidator {
    func validate(_ city: String) -> (Bool, String) {
        return (city.count >= 3, "Your city name is too short".localized())
    }
}

struct StateValidator {
    func validate(_ state: String) -> (Bool, String) {
        return (state.count >= 2, "Your state name is too short".localized())
    }
}

struct PinCodeValidator {
    func validate(_ pin: String) -> (Bool, String) {
        return (pin.count == 6, "Invalid pin code".localized())
    }
}

