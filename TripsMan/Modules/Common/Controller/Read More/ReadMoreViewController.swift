//
//  ReadMoreViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/02/23.
//

import UIKit

class ReadMoreViewController: UIViewController {
    
    @IBOutlet weak var readMoreLabel: UILabel!
    
    var readMore: ReadMore?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\n\n-----\(readMoreContent)")
        
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
            
        } else  if let readMoreContent = readMoreContent {
            let  content = readMoreContent
            readMoreLabel.setAttributedHtmlText(content)
            self.title = pageTitle
        }
        
        
    }

}

protocol ReadMoreDelegate {
    func showReadMore(for type: ReadMoreTypes, content: NSAttributedString?)
}

struct ReadMore {
    var title: String
    var content: String
}
