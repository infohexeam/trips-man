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
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        print("\n\ndescLabel: \(descDetails.text)")
        delegate?.showReadMore(for: .activityDescription, content: descDetails.text)
    }
}
