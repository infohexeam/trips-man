//
//  LoginViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var loginButton: DisableButton!
    @IBOutlet weak var signupGoogleButton: UIButton!
    @IBOutlet weak var signupAppleButton: UIButton!
    @IBOutlet weak var signupAccountButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        for each in textFields {
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        hideKeyboardOnTap()
    }
    
    func setupView() {
        //Hide Validation Labels
        emailValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        //Disable Login Button
        loginButton.isEnabled = false
        
    }
    
 
    //MARK: UIButton Actions
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
}

//MARK: UITextField
extension LoginViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == emailField {
            return EmailValidator().validate(text)
        } else if textField == passwordField {
            return PasswordValidator().validate(text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == emailField {
            emailValidationLabel.text = message
            UIView.animate(withDuration: 0.25, animations: {
                self.emailValidationLabel.isHidden = valid
                
            })
        } else if textField == passwordField {
            UIView.animate(withDuration: 0.25, animations: {
                self.passwordValidationLabel.text = message
                self.passwordValidationLabel.isHidden = valid
            })
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == emailField {
                if valid {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.emailValidationLabel.isHidden = true
                    })
                } else {
                    isFormValid = false
                    emailValidationLabel.text = message
                }
            } else if each == passwordField {
                if valid {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.passwordValidationLabel.isHidden = true
                    })
                } else {
                    isFormValid = false
                    passwordValidationLabel.text = message
                }
            }
        }
        
        loginButton.isEnabled = isFormValid
    }
}
