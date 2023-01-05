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
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var newPasswordValidationLabel: UILabel!
    @IBOutlet weak var confirmPasswordValidationLabel: UILabel!
    
    @IBOutlet weak var submitButton: DisableButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        hideKeyboardOnTap()
        
        for each in textFields {
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
    }
    
    func setupView() {
        //Hide Validation Labels
        newPasswordValidationLabel.isHidden = true
        confirmPasswordValidationLabel.isHidden = true
        
        //Disable Login Button
        submitButton.isEnabled = false
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        
    }
    
}

//MARK: UITextField
extension ResetPasswordViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == newPasswordField {
            return PasswordValidator().validate(text)
        } else if textField == confirmPasswordField {
            return PasswordValidator().retypeValidate(newPasswordField.text ?? "", text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == newPasswordField {
            newPasswordValidationLabel.text = message
            UIView.animate(withDuration: 0.25, animations: {
                self.newPasswordValidationLabel.isHidden = valid
                
            })
        } else if textField == confirmPasswordField {
            UIView.animate(withDuration: 0.25, animations: {
                self.confirmPasswordValidationLabel.text = message
                self.confirmPasswordValidationLabel.isHidden = valid
            })
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == newPasswordField {
                if valid {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.newPasswordValidationLabel.isHidden = true
                    })
                } else {
                    isFormValid = false
                    newPasswordValidationLabel.text = message
                }
            } else if each == confirmPasswordField {
                if valid {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.confirmPasswordValidationLabel.isHidden = true
                    })
                } else {
                    isFormValid = false
                    confirmPasswordValidationLabel.text = message
                }
            }
        }
        
        submitButton.isEnabled = isFormValid
    }
}
