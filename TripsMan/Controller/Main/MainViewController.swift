//
//  MainViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    

}
