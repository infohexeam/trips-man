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

struct PasswordValidator {
    func validate(_ password: String) -> (Bool, String) {
        return (password.count >= 6, "Your password is too short")
    }
    
    func retypeValidate(_ password: String, _ retype: String) -> (Bool, String) {
        return (password == retype, "Password mismatch")
    }
}

struct NameValidator {
    func validate(_ name: String) -> (Bool, String) {
        return (name.count >= 3, "Your name is too short")
    }
}


struct MobileValidator {
    func validate(_ mobile: String) -> (Bool, String) {
        return (mobile.count >= 10, "Invalid mobile number")
    }
}

struct OTPValidator {
    func validate(_ otp: String) -> (Bool, String) {
        return (otp.count >= 4, "Invalid otp")
    }
}

