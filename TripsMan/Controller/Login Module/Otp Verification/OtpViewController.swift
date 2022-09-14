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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
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
        
    }
    
    @IBAction func resendTapped(_ sender: UIButton) {
        
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

