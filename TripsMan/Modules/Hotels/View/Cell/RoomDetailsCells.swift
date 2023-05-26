//
//  RoomDetailsCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/05/23.
//

import Foundation
import UIKit

class RoomDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var roomDescription: UILabel!
}

class RoomPriceDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var pricePerNight: UILabel!
    @IBOutlet weak var taxAndFees: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
}
