//
//  LoginViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit
import Toast_Swift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var userNameValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var loginButton: DisableButton!
    @IBOutlet weak var signupGoogleButton: UIButton!
    @IBOutlet weak var signupAppleButton: UIButton!
    @IBOutlet weak var signupAccountButton: UIButton!
    
    let parser = Parser()
    
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
        userNameValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        //Disable Login Button
        loginButton.isEnabled = false
        
    }
    
 
    //MARK: UIButton Actions
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OtpViewController {
            if let userName = sender as? String {
                if userName == "email" {
                    vc.email = userNameField.text!
                    vc.isMobile = false
                } else {
                    vc.mobile = userNameField.text!
                    vc.isMobile = true
                }
            }
        }
    }
}

//MARK: - APICalls
extension LoginViewController {
    func login() {
        showIndicator()
        let params: [String: Any] = ["UserName": userNameField.text!,
                                     "Password": passwordField.text!]
        
        parser.sendRequest(url: "api/account/login", http: .post, parameters: params) { (result: LoginData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        SessionManager.shared.saveLoginDetails(result!)
                        sideMenuDelegate?.updateSideMenu()
                        self.dismiss(animated: true)
                    } else if result!.status == 3 { //email not verified
                        self.performSegue(withIdentifier: "toOtp", sender: "email")
                    } else if result!.status == 4 {
                        self.performSegue(withIdentifier: "toOtp", sender: "mobile")
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
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
        
        if textField == userNameField {
            return UserNameValidator().validate(text)
        } else if textField == passwordField {
            return PasswordValidator().validate(text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == userNameField {
            userNameValidationLabel.text = message
            UIView.animate(withDuration: 0.25, animations: {
                self.userNameValidationLabel.isHidden = valid
                
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
            if each == userNameField {
                if valid {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.userNameValidationLabel.isHidden = true
                    })
                } else {
                    isFormValid = false
                    userNameValidationLabel.text = message
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
