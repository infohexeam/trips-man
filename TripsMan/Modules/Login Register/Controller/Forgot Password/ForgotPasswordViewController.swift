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
    
    let parser = Parser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        hideKeyboardOnTap()
        emailField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    func setupView() {
        //Hide Validation Label
        emailValidationLabel.isHidden = true
        
        //Disable
        submitButton.isEnabled = false
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        sendResetLink()
        
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - APICalls
extension ForgotPasswordViewController {
    func sendResetLink() {
        showIndicator()
        let params: [String: Any] = ["Email": emailField.text!]
        
        parser.sendRequest(url: "api/account/GenerateCustomerPasswordResetToken", http: .post, parameters: params) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        let alert = UIAlertController(title: "", message: result!.message, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                            self.dismiss(animated: true)
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true)
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
extension ForgotPasswordViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == emailField {
            return EmailValidator().validate(text)
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
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        let (valid, message) = validate(textField)
        if textField == emailField {
            if valid {
                UIView.animate(withDuration: 0.25, animations: {
                    self.emailValidationLabel.isHidden = true
                })
            } else {
                isFormValid = false
                emailValidationLabel.text = message
            }
        }
        submitButton.isEnabled = isFormValid
    }
}

