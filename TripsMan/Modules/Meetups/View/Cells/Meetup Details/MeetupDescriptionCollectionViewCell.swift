//
//  MeetupDescriptionCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 08/05/23.
//

import UIKit

class MeetupDescriptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var descTitle: UILabel!
    @IBOutlet weak var descDetails: UILabel!
    @IBOutlet weak var readMoreView: UIView!
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        delegate?.showReadMore(descDetails.tag)
    }
}
