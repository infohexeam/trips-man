//
//  MyTripsCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/12/22.
//

import Foundation
import UIKit

class TripListCell: UICollectionViewCell {
    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var bookedDate: UILabel!
    @IBOutlet weak var primaryGuest: UILabel!
    @IBOutlet weak var roomCount: UILabel!
}

