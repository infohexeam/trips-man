//
//  UITextField+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/10/22.
//

import Foundation
import UIKit

extension UITextField {
    func alignForLanguage() {
        if SessionManager.shared.getLanguage().code == "ar" {
            self.textAlignment = .right
        } else {
            self.textAlignment = .left
        }
    }
}
