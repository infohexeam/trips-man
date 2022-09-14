//
//  ResetPasswordViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/09/22.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var newPasswordField: CustomTextField!
    @IBOutlet weak var confirmPasswordField: CustomTextField!
    
    @IBOutlet weak var newPasswordValidationLabel: UILabel!
    @IBOutlet weak var confirmPasswordValidationLabel: UILabel!
    
    @IBOutlet weak var submitButton: DisableButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        //Hide Validation Labels
        newPasswordValidationLabel.isHidden = true
        confirmPasswordValidationLabel.isHidden = true
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
    }
    
}
