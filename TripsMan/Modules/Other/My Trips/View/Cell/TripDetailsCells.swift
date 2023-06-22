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
    @IBOutlet weak var bookedDate: UILabel!
    @IBOutlet weak var tripMessage: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    
}

class TripMoreDetailsCell: UICollectionViewCell {
    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftText: UILabel!
    @IBOutlet weak var leftSubText: UILabel!
    
    @IBOutlet weak var rightTitle: UILabel!
    @IBOutlet weak var rightText: UILabel!
    @IBOutlet weak var rightSubText: UILabel!
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
