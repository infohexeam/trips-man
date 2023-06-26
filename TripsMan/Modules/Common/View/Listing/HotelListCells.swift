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
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var sponsoredView: UIView!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    @IBOutlet weak var ratingMainView: UIView!
    @IBOutlet weak var starRating: UILabel!
    @IBOutlet weak var userRatingText: UILabel!
    @IBOutlet weak var userRatingView: UIView!
    @IBOutlet weak var userRatingLabel: UILabel!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
   
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
}

class HotelListAdCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bannerImage: UIImageView!
    
}
