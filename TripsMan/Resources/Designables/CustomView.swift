//
//  CustomView.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import Foundation
import UIKit

@IBDesignable
class CustomView: UIView {
    
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
    
    @IBInspectable var bottomCorner: Bool = false {
        didSet {
            if bottomCorner == true {
                self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            }
        }
    }
    
    @IBInspectable var bottomShadow: Bool = false {
        didSet {
            layer.masksToBounds = false
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.5
            layer.shadowColor = UIColor.gray.cgColor
            layer.shadowOffset = CGSize(width: 0 , height:2)
        }
    }
    
    //PrepareForInterfaceBuilder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
//        layer.borderColor = borderColor?.cgColor
//        layer.borderWidth = borderWidth
//        layer.cornerRadius = cornerRadius
//        if bottomCorner == true {
//            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//        }
    }
}
