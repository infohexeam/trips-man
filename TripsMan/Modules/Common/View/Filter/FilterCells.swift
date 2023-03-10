//
//  FilterCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 16/01/23.
//

import Foundation
import UIKit
import RangeSeekSlider

class FilterListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView(frame: bounds)
        view.backgroundColor = UIColor(named: "seperatorColor")
 //       view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 10
        self.backgroundView = view
        
        let coloredView = UIView(frame: bounds)
        coloredView.backgroundColor = UIColor(named: "secondaryColor")
        coloredView.layer.cornerRadius = 10
        self.selectedBackgroundView = coloredView
    }
}

class FilterRangeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        rangeSlider.layoutIfNeeded()
//        rangeSlider.updateLayerFramesAndPositions()
//    }
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        rangeSlide()
//    }
}

//Header
class FiltersHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
}

//Footer
class FilterFooterView: UICollectionReusableView {
    
}

