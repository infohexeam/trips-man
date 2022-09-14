//
//  ForgotPasswordViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/09/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: CustomTextField!
    
    @IBOutlet weak var emailValidationLabel: UILabel!
    
    @IBOutlet weak var submitButton: DisableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        //Hide Validation Label
        emailValidationLabel.isHidden = true
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toResetPassword", sender: nil)
        
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
