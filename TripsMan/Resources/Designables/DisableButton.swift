//
//  CustomButton.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import Foundation
import UIKit

@IBDesignable
class DisableButton: UIButton {
    
    enum ButtonState {
        case normal
        case disabled
    }

    @IBInspectable var disabledBackgroundColor: UIColor?
    @IBInspectable var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
//    @IBInspectable var textColor: UIColor?
    
    //change background color on isEnabled value changed
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultBackgroundColor {
                    self.backgroundColor = color
                    
                }
            }
            else {
                if let color = disabledBackgroundColor {
                    self.backgroundColor = color
                }
            }
        }
    }
    
    //custom functions to set color for different state
    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }
}
