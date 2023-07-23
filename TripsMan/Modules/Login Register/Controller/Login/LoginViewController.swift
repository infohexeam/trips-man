//
//  LoginViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit
import Toast_Swift
import AuthenticationServices
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameField: CustomTextField!
    @IBOutlet weak var passwordField: CustomTextField!
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var userNameValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    
    @IBOutlet weak var loginButton: DisableButton!
    @IBOutlet weak var signupGoogleButton: UIButton!
    @IBOutlet weak var signupAppleButton: ASAuthorizationAppleIDButton!
    @IBOutlet weak var signupAccountButton: UIButton!
    
    @IBOutlet weak var eyeButton: UIButton!
    
    let parser = Parser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        hideKeyboardOnTap()
        
        for each in textFields {
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
            each.alignForLanguage()
        }
    }
    
    func setupView() {
        //Hide Validation Labels
        userNameValidationLabel.isHidden = true
        passwordValidationLabel.isHidden = true
        
        //Disable Login Button
        loginButton.isEnabled = false
        
        eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
        if SessionManager.shared.getLanguage().code == "ar" {
            passwordField.paddingLeft = 35
        } else {
            passwordField.paddingRight = 35
        }
        
    }
    
    func clearFields() {
        userNameField.text = ""
        passwordField.text = ""
    }
    
    func signUpWithapple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signInWithGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }

            print("Google Sign in success - \(String(describing: signInResult?.user))")
          }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: K.bundleIdentifier, account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
 
    //MARK: UIButton Actions
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toForgotPassword", sender: nil)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        login()
    }
    
    @IBAction func signupTapped(_ sender: UIButton) {
        if sender == signupAppleButton {
//            signUpWithapple()
        } else if sender == signupGoogleButton {
//            signInWithGoogle()
        } else if sender == signupAccountButton {
            performSegue(withIdentifier: "toRegister", sender: nil)
        }
        
    }
    
    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        eyeButton.isSelected = !eyeButton.isSelected
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry
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
                                     "Password": passwordField.text!,
                                     "DeviceUid": UIDevice.current.identifierForVendor!.uuidString,
                                     "DeviceModel": UIDevice.modelName,
                                     "DeviceManufaturer": "Apple",
                                     "OperatingSystem": UIDevice.current.systemName,
                                     "OSVersion": UIDevice.current.systemVersion,
                                     "FirebaseToken": SessionManager.shared.getFcmToken() ?? ""]
        
        parser.sendRequest(url: "api/account/login", http: .post, parameters: params) { (result: LoginData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        SessionManager.shared.saveLoginDetails(result!)
                        sideMenuDelegate?.updateSideMenu()
                        self.dismiss(animated: true)
                        self.clearFields()
                    } else if result!.status == 3 { //email not verified
                        self.performSegue(withIdentifier: "toOtp", sender: "email")
                        self.clearFields()
                    } else if result!.status == 4 {
                        self.performSegue(withIdentifier: "toOtp", sender: "mobile")
                        self.clearFields()
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

//MARK: UITextField
extension LoginViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, Validation.emptyFieldMessage)
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

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
        let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
        
        //TODO: -
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
