//
//  RoomSelectionSummaryCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/09/22.
//

import Foundation
import UIKit

class BookSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var checkinLabel: UILabel!
    @IBOutlet weak var checkoutLabel: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var roomType: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hotelImage: UIImageView!
    
}

class PrimaryGuestCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageAndGender: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
}

class OtherGuestCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageAndGender: UILabel!
    
}

class CouponCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var couponCode: UILabel!
    @IBOutlet weak var couponDesc: UILabel!
    @IBOutlet weak var radioImage: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var delegate: CouponDelegate?
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        delegate?.couponRemoved(index: sender.tag)
    }
}

class PriceDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var seperator: UIView!
}

class RewardPointCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var rewardButton: UIButton!
    @IBOutlet weak var rewardLabel: UILabel!
}


class CouponFooterView: UICollectionReusableView {
    @IBOutlet weak var footerButton: UIButton!
    
}
