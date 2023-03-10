//
//  HotelListCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/09/22.
//

import UIKit
import Cosmos

class HotelListFilterCollectionViewCell: UICollectionViewCell {
    
}

class HotelListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hotelImage: UIImageView!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var hotelAddress: UILabel!
    @IBOutlet weak var sponsoredView: UIView!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    @IBOutlet weak var rightRatingLabel: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingLabelView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var starRating: UILabel!
}

class HotelListAdCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    
}
