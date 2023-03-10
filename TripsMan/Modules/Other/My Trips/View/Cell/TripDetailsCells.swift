//
//  TripDetailsCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/02/23.
//

import Foundation
import UIKit
import Cosmos


class TripDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tripStatus: UILabel!
    @IBOutlet weak var bookingID: UILabel!
    @IBOutlet weak var tripMessage: UILabel!
    
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var hotelImage: UIImageView!
    @IBOutlet weak var hotelAddress: UILabel!
    @IBOutlet weak var checkinDate: UILabel!
    @IBOutlet weak var checkinTime: UILabel!
    @IBOutlet weak var checkoutDate: UILabel!
    @IBOutlet weak var checkoutTime: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var primaryGuest: UILabel!
    @IBOutlet weak var roomType: UILabel!
    @IBOutlet weak var tripSpec: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
}


class AddReviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ratedView: UIView!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewTitleLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addReviewButton: UIButton!
    
    var delegate: AddReviewDelegate?
    
    @IBAction func addReviewTapped(_ sender: UIButton) {
        delegate?.addReviewClicked()
    }
}

class TripDetailsActionCollectionViewCell: UICollectionViewCell {
    
}

protocol AddReviewDelegate {
    
    func refreshReview()
    func addReviewClicked()
}
