//
//  ActivityDescriptionCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/04/23.
//

import UIKit

class ActivityDescriptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var descTitle: UILabel!
    @IBOutlet weak var descDetails: UILabel!
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        print("\n\ndescLabel: \(descDetails.text)")
        delegate?.showReadMore(for: .activityDescription, content: descDetails.text)
    }
    
}
