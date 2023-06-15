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
        
        if let readMore = readMore {
            readMoreLabel.setAttributedHtmlText(readMore.content)
            self.title = readMore.title
        }
        
        
    }

}

protocol ReadMoreDelegate {
    func showReadMore(_ tag: Int)
}

struct ReadMore {
    var title: String
    var content: String
}
