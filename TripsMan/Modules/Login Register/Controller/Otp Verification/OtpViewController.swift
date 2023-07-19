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
    @IBOutlet weak var resendButton: DisableButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resendText: UILabel!
    
    var email = ""
    var mobile = ""
    var isMobile = true
    let parser = Parser()
    
    var timer: Timer?
    
    var otpTime = K.otpTimer
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        hideKeyboardOnTap()
        if isMobile {
            messageLabel.text = "Please enter the OTP sent to your mobile number".localized()
            verifyButton.setTitle("Verify Mobile".localized(), for: .normal)
            generateOTP()
        } else {
            messageLabel.text = "Please enter the OTP sent to your email".localized()
            verifyButton.setTitle("Verify Email".localized(), for: .normal)
            generateEmailOTP()
        }
        
        
        otpField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    func setupView() {
        //Hide Validation Labels
        otpValidationLabel.isHidden = true
        
        //Disable Verify Button
        verifyButton.isEnabled = false
        
        
        resendText.isHidden = true
    }
    
    func clearFields() {
        otpField.text = ""
    }
    
    func startTimer() {
        timer?.invalidate()
        resendButton.isEnabled = false
        resendText.isHidden = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.handleTimer(timer)
        }
        timer?.fire()
    }
    
    func handleTimer(_ timer: Timer) {
        otpTime -= 1
        resendText.text = "Resend OTP in".localized() + " \(otpTime)"
        guard otpTime >= 0 else {
            otpTime = K.otpTimer
            resendText.isHidden = true
            resendButton.isEnabled = true
            timer.invalidate()
            return
        }
    }
    
    
    //MARK: UIButton Actions
    @IBAction func verifyTapped(_ sender: UIButton) {
        if isMobile {
            verifyOTP()
        } else {
            verifyEmailOTP()
        }
    }
    
    @IBAction func resendTapped(_ sender: UIButton) {
        if isMobile {
            generateOTP()
        } else {
            generateEmailOTP()
        }
    }
}

//MARK: - APICalls
extension OtpViewController {
    func generateOTP() {
        showIndicator()
        let params: [String: Any] = ["Mobile": mobile]
        
        parser.sendRequest(url: "api/account/Generateotp", http: .post, parameters: params) { (result: RegisterData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        if self.timer != nil {
                            self.view.makeToast(K.otpSentSuccessMessage)
                        }
                        self.startTimer()
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
    
    func generateEmailOTP() {
        showIndicator()
        let params: [String: Any] = ["Email": email]
        
        parser.sendRequest(url: "api/account/GenerateEmailOtp", http: .post, parameters: params) { (result: RegisterData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        if self.timer != nil {
                            self.view.makeToast(K.otpSentSuccessMessage)
                        }
                        self.startTimer()
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
    
    func verifyOTP() {
        showIndicator()
        let params: [String: Any] = ["Mobile": mobile,
                                     "otp": otpField.text!]
        
        parser.sendRequest(url: "api/account/Verifyotp", http: .post, parameters: params) { (result: RegisterData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.navigationController?.view.makeToast(result!.message)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.view.makeToast(K.otpFailureMessage)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
            }
        }
    }
    
    func verifyEmailOTP() {
        showIndicator()
        let params: [String: Any] = ["Email": email,
                                     "otp": otpField.text!]
        
        parser.sendRequest(url: "api/account/VerifyEmailotp", http: .post, parameters: params) { (result: RegisterData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.navigationController?.view.makeToast(result!.message)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.view.makeToast(K.otpFailureMessage)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
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
            return (false, Validation.invalidOtpMessage)
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

