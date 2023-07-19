//
//  ResetPasswordViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/09/22.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var currentPasswordView: UIView!

    @IBOutlet weak var currentPassword: CustomTextField!
    @IBOutlet weak var newPasswordField: CustomTextField!
    @IBOutlet weak var confirmPasswordField: CustomTextField!
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var currentPasswordValidationLabel: UILabel!
    @IBOutlet weak var newPasswordValidationLabel: UILabel!
    @IBOutlet weak var confirmPasswordValidationLabel: UILabel!
    
    @IBOutlet weak var submitButton: DisableButton!
    
    @IBOutlet weak var currPwdEyeButton: UIButton!
    @IBOutlet weak var newPwdEyeButton: UIButton!
    @IBOutlet weak var retypePwdEyeButton: UIButton!
    
    var token = ""
    var email = ""
    
    let parser = Parser()
    
    var isChangePassword = false
    
    
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
        currentPasswordValidationLabel.isHidden = true
        newPasswordValidationLabel.isHidden = true
        confirmPasswordValidationLabel.isHidden = true
        
        //Disable Login Button
        submitButton.isEnabled = false
        
        //Page Title
        if isChangePassword {
            pageTitle.text = "CHANGE PASSWORD".localized()
        } else {
            pageTitle.text = "RESET PASSWORD".localized()
            currentPasswordView.isHidden = true
        }
        
        
        //EyeButton
        currPwdEyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        currPwdEyeButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        newPwdEyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        newPwdEyeButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        retypePwdEyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        retypePwdEyeButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        currentPassword.setLeftPaddingPoints(30)
        newPasswordField.setLeftPaddingPoints(30)
        confirmPasswordField.setLeftPaddingPoints(30)
    }
    
    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        if sender == currPwdEyeButton {
            currPwdEyeButton.isSelected = !currPwdEyeButton.isSelected
            currentPassword.isSecureTextEntry = !currentPassword.isSecureTextEntry
        } else if sender == newPwdEyeButton {
            newPwdEyeButton.isSelected = !newPwdEyeButton.isSelected
            newPasswordField.isSecureTextEntry = !newPasswordField.isSecureTextEntry
        } else if sender == retypePwdEyeButton {
            retypePwdEyeButton.isSelected = !retypePwdEyeButton.isSelected
            confirmPasswordField.isSecureTextEntry = !confirmPasswordField.isSecureTextEntry
        }
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if isChangePassword {
            changePassword()
        } else {
            resetPassword()
        }
    }
}

//MARK: - APICalls
extension ResetPasswordViewController {
    func changePassword() {
        showIndicator()
        let params: [String: Any] = ["OldPassword": currentPassword.text!,
                                     "Password": confirmPasswordField.text!]
        
        parser.sendRequestLoggedIn(url: "api/account/ChangeCustomerPassword", http: .post, parameters: params, isAuth: true) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                if error == nil {
                    if result!.status == 1 {
                        self.view.makeToast(result!.message)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.hideIndicator()
                            self.dismiss(animated: true)
                         }
                        
                    } else {
                        self.hideIndicator()
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.hideIndicator()
                    self.view.makeToast(K.apiErrorMessage)
                }
            }
        }
    }
    
    func resetPassword() {
        showIndicator()
        let params: [String: Any] = ["Email": email,
                                     "Password": confirmPasswordField.text!,
                                     "ReturnUrl": token]
        
        parser.sendRequest(url: "api/account/ResetPassword", http: .post, parameters: params) { (result: BasicResponse?, error) in
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
                    self.view.makeToast(K.apiErrorMessage)
                }
            }
        }
    }
}

//MARK: - UITextField
extension ResetPasswordViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, Validation.emptyFieldMessage)
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
        if textField == currentPassword {
            currentPasswordValidationLabel.text = message
            UIView.animate(withDuration: 0.25, animations: {
                self.currentPasswordValidationLabel.isHidden = valid
            })
        } else if textField == newPasswordField {
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
            if each == currentPassword {
                if isChangePassword {
                    if valid {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.currentPasswordValidationLabel.isHidden = true
                        })
                    } else {
                        isFormValid = false
                        currentPasswordValidationLabel.text = message
                    }
                }
            } else if each == newPasswordField {
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
