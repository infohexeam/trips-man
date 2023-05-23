//
//  CustomTextField.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import Foundation
import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                backgroundColor = UIColor(named: "Disabled Field")
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat = 5
    @IBInspectable var paddingRight: CGFloat = 5
    
    //PrepareForInterfaceBuilder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
//        layer.borderColor = borderColor?.cgColor
//        layer.borderWidth = borderWidth
//        layer.cornerRadius = cornerRadius
    }
    
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x + paddingLeft, bounds.origin.y,
                          bounds.size.width - paddingLeft - paddingRight, bounds.size.height)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
}
