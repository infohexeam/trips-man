//
//  ActivityDetailsCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/04/23.
//

import UIKit

class ActivityDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var activityCode: UILabel!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityCountry: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var memberAddButton: UIButton!
    @IBOutlet weak var memberMinusButton: UIButton!
    
    var memberCount = 1
    var delegate: MemberCountDelegate?
    
    @IBAction func memberButtonTapped(_ sender: UIButton) {
        if sender == memberAddButton {
            memberCount += 1
            memberLabel.text = "\(memberCount) " + "Members".localized()
            delegate?.memberCoundDidChanged(to: memberCount)
        } else if sender == memberMinusButton {
            if memberCount > 1 {
                memberCount -= 1
                memberLabel.text = "\(memberCount.oneOrMany("Member"))"
                delegate?.memberCoundDidChanged(to: memberCount)
            }
        }
    }
}


protocol MemberCountDelegate {
    func memberCoundDidChanged(to count: Int)
}
