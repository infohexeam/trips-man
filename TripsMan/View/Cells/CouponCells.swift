//
//  CouponCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/02/23.
//

import Foundation
import UIKit

class CouponCodeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var couponCodeField: UITextField!
    
    var delegate: CouponCodeDelegate?
    
    @IBAction func applyDidTapped(_ sender: UIButton) {
        if couponCodeField.text?.trimmingCharacters(in: .whitespaces) != "" {
            delegate?.couponCodeDidApplied(couponCode: couponCodeField.text!)
        }
    }
}

protocol CouponCodeDelegate {
    func couponCodeDidApplied(couponCode: String)
}
