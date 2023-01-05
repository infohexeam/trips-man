//
//  HotelDetailCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 26/09/22.
//

import Foundation
import UIKit
import MapKit

class HotelImageCollectionViewCell: UICollectionViewCell {
    
}

class HotelDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var detailsLabel: UILabel!
    
}

class HotelAddrressCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var addressMap: MKMapView!
}

class HotelFacilitiesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var facilityLabel: UILabel!
    @IBOutlet weak var facilityIcon: UIImageView!
    @IBOutlet weak var moreView: UIView!
    
}

class SeperatorCell: UICollectionViewCell {
    
}

class RoomFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!
    
    @IBOutlet weak var roomAddButton: UIButton!
    @IBOutlet weak var roomMinusButton: UIButton!
    @IBOutlet weak var adultAddButton: UIButton!
    @IBOutlet weak var adultMinusButton: UIButton!
    @IBOutlet weak var childAddButton: UIButton!
    @IBOutlet weak var childMinusButton: UIButton!
    
    var roomQty = 0 {
        didSet {
            if roomQty == 1 {
                roomLabel.text = "\(roomQty) Room"
            } else {
                roomLabel.text = "\(roomQty) Rooms"
            }
        }
    }
    
    var adultQty = 0 {
        didSet {
            if adultQty == 1 {
                adultLabel.text = "\(adultQty) Adult"
            } else {
                adultLabel.text = "\(adultQty) Adults"
            }
        }
    }
    
    var childQty = 0 {
        didSet {
            if childQty == 1 {
                childLabel.text = "\(childQty) Child"
            } else {
                childLabel.text = "\(childQty) Children"
            }
        }
    }
    
    var checkin = "" {
        didSet {
            checkinField.text = checkin
        }
    }
    var checkout = "" {
        didSet {
            checkoutField.text = checkout
        }
    }
    
    func setupView() {
        roomQty = 1
        adultQty = 1
        childQty = 0
    }
    
    func addOrMinusPeople(_ sender: UIButton) {
        if sender == roomAddButton {
            roomQty += 1
        } else if sender == roomMinusButton {
            if roomQty > 1 {
                roomQty -= 1
            }
        } else if sender == adultAddButton {
            adultQty += 1
        } else if sender == adultMinusButton {
            if adultQty > 1 {
                adultQty -= 1
            }
        } else if sender == childAddButton {
            childQty += 1
        } else if sender == childMinusButton {
            if childQty > 0 {
                childQty -= 1
            }
        }
    }
    
    @IBAction func addOrMinusTapped(_ sender: UIButton) {
        addOrMinusPeople(sender)
    }
}

class HotelRoomsCollectionViewCell: UICollectionViewCell {
    
    var delegate: ViewImageDelegate?
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    
    @IBAction func imageTapped(_ sender: UIButton) {
        delegate?.imageTapped(sender.tag  )
    }
    
}

class PropertyRulesCollectionViewCell: UICollectionViewCell {
    
}

class TermsCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet weak var termsLabel: UILabel!
    
}

class RatingCollectionViewCell: UICollectionViewCell {
    
}

class ReviewCollectionViewCell: UICollectionViewCell {
    
}

class ImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roomImage: UIImageView!
}


//Headers
class HotelDetailsHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
}


protocol ViewImageDelegate {
    func imageTapped(_ tag: Int)
}
