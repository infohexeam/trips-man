//
//  RegisterViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/09/22.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameField: CustomTextField!
    @IBOutlet weak var mobileField: CustomTextField!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet weak var retypePasswordField: CustomTextField!
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var mobileValidationLabel: UILabel!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var retypePasswordValidationLabel: UILabel!
    
    @IBOutlet weak var registerButton: DisableButton!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    let parser = Parser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        hideKeyboardOnTap()
        
        for each in textFields {
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        
//        containerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    func setupView() {
        //Hide Validation Labels
        for each in [nameValidationLabel, mobileValidationLabel, emailValidationLabel, passwordValidationLabel, retypePasswordValidationLabel] {
            each?.isHidden = true
        }
        
        //Clear Text Fields
        for each in [nameField, mobileField, emailField, passwordField, retypePasswordField] {
            each?.text = ""
        }
        
        //Disable Register Button
        registerButton.isEnabled = false
    }
    
    
    //MARK: UIButton Actions
    @IBAction func registerTapped(_ sender: UIButton) {
        register()
    }
    
    @IBAction func clearTapped(_ sender: UIButton) {
        setupView()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OtpViewController {
            vc.email = emailField.text!
        }
    }
}

//MARK: - APICalls
extension RegisterViewController {
    func register() {
        showIndicator()
        let params: [String: Any] = ["Email": emailField.text!,
                                     "PhoneNumber": mobileField.text!,
                                     "Password": passwordField.text!,
                                     "ConfirmPassword": retypePasswordField.text!,
                                     "UserTypeId": 1,
                                     "FullName": nameField.text!]
        
        parser.sendRequest(url: "api/account/Register", http: .post, parameters: params) { (result: RegisterData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.performSegue(withIdentifier: "toOtpVerification", sender: nil)
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
extension RegisterViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == nameField {
            return NameValidator().validate(text)
        } else if textField == mobileField {
            return MobileValidator().validate(text)
        } else if textField == emailField {
            return EmailValidator().validate(text)
        } else if textField == passwordField {
            return PasswordValidator().validate(text)
        } else if textField == retypePasswordField {
            return PasswordValidator().retypeValidate(passwordField.text ?? "", text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == nameField {
            nameValidationLabel.text = message
            nameValidationLabel.isHidden = valid
        } else if textField == mobileField {
            mobileValidationLabel.text = message
            mobileValidationLabel.isHidden = valid
        } else if textField == emailField {
            emailValidationLabel.text = message
            emailValidationLabel.isHidden = valid
        } else if textField == passwordField {
            passwordValidationLabel.text = message
            passwordValidationLabel.isHidden = valid
        } else if textField == retypePasswordField {
            retypePasswordValidationLabel.text = message
            retypePasswordValidationLabel.isHidden = valid
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == nameField {
                if valid {
                    nameValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    nameValidationLabel.text = message
                }
            } else if each == mobileField {
                if valid {
                    mobileValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    mobileValidationLabel.text = message
                }
            } else if each == emailField {
                if valid {
                    emailValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    emailValidationLabel.text = message
                }
            } else if each == passwordField {
                if valid {
                    passwordValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    passwordValidationLabel.text = message
                }
            } else if each == retypePasswordField {
                if valid {
                    retypePasswordValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    retypePasswordValidationLabel.text = message
                }
            }
        }
        
        registerButton.isEnabled = isFormValid
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameField {
            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let allowedCharacterSet = CharacterSet(charactersIn: allowedCharacters)
            let typedCharacterSet = CharacterSet(charactersIn: string)
            let alphabet = allowedCharacterSet.isSuperset(of: typedCharacterSet)
            return alphabet
            
            
        } else {
            return true
        }
    }
}


