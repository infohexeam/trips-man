//
//  OtpViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/09/22.
//

import UIKit

class OtpViewController: UIViewController {

    @IBOutlet weak var otpField: CustomTextField!
    
    @IBOutlet weak var otpValidationLabel: UILabel!
    
    @IBOutlet weak var verifyButton: DisableButton!
    
    var email = ""
    var mobile = ""
    var isMobile = true
    let parser = Parser()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        hideKeyboardOnTap()
        generateOTP()
        
        otpField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    func setupView() {
        //Hide Validation Labels
        otpValidationLabel.isHidden = true
        
        //Disable Verify Button
        verifyButton.isEnabled = false
    }
    
    //MARK: UIButton Actions
    @IBAction func verifyTapped(_ sender: UIButton) {
        verifyOTP()
    }
    
    @IBAction func resendTapped(_ sender: UIButton) {
        generateOTP()
    }
}

//MARK: - APICalls
extension OtpViewController {
    func generateOTP() {
        showIndicator()
        let params: [String: Any] = ["Email": email]
        
        parser.sendRequest(url: "api/account/Generateotp", http: .post, parameters: params) { (result: LoginData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    func verifyOTP() {
        showIndicator()
        let params: [String: Any] = ["Email": email,
                                     "otp": otpField.text!]
        
        parser.sendRequest(url: "api/account/Verifyotp", http: .post, parameters: params) { (result: LoginData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.navigationController?.view.makeToast(result!.message)
                        self.navigationController?.popToRootViewController(animated: true)
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
extension OtpViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "Invalid otp.")
        }
        
        if textField == otpField {
            return OTPValidator().validate(text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == otpField {
            UIView.animate(withDuration: 0.25, animations: {
                self.otpValidationLabel.text = message
                self.otpValidationLabel.isHidden = valid
            })
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        let (valid, message) = validate(textField)
        if valid {
            UIView.animate(withDuration: 0.25, animations: {
                self.otpValidationLabel.isHidden = true
            })
        } else {
            isFormValid = false
            otpValidationLabel.text = message
        }
        
        verifyButton.isEnabled = isFormValid
    }
}

