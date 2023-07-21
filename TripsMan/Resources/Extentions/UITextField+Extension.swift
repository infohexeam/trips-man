//
//  UITextField+Extension.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/10/22.
//

import Foundation
import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func alignForLanguage() {
        if SessionManager.shared.getLanguage().code == "ar" {
            self.textAlignment = .right
        } else {
            self.textAlignment = .left
        }
    }
}
