//
//  PackageSummaryCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 24/03/23.
//

import UIKit

class PackageSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var packageImage: UIImageView!
    @IBOutlet weak var packageName: UILabel!
    @IBOutlet weak var packagePrice: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var startDate: UITextField!
    
    func setupView() {
        startDate.alignForLanguage()
    }
}
