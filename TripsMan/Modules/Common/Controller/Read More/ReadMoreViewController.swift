//
//  ReadMoreViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/02/23.
//

import UIKit

class ReadMoreViewController: UIViewController {
    
    @IBOutlet weak var readMoreLabel: UILabel!
    
    var type: ReadMoreTypes?
    var hotelDetails: HotelDetails?
    var readMoreContent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let hotelDetails = hotelDetails {
            var content = ""
            var pageTitle = ""
            if type == .details {
                content = hotelDetails.description
                pageTitle = hotelDetails.hotelName
            } else if type == .rules {
                content = hotelDetails.propertyRules
                pageTitle = "Property Rules"
            } else if type == .terms {
                content = hotelDetails.termsAndCondition
                pageTitle = "Terms and Conditions"
            }
            
            if let readMoreContent = readMoreContent {
                content = readMoreContent
            }
            
            readMoreLabel.setAttributedHtmlText(content)
            self.title = pageTitle
            
        }
        
    }

}

protocol ReadMoreDelegate {
    func showReadMore(for type: ReadMoreTypes)
}

enum ReadMoreTypes {
    case details
    case rules
    case terms
    case activityDescription
}
