//
//  RoomSelectionCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/09/22.
//

import Foundation
import UIKit

class RoomSummaryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    
}

class PrimaryFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    @IBOutlet weak var primayGuestField: CustomTextField!
    @IBOutlet weak var contactField: CustomTextField!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var genderField: CustomTextField!
    @IBOutlet weak var ageField: CustomTextField!
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var phoneValidationLabel: UILabel!
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var genderValidationLabel: UILabel!
    @IBOutlet weak var ageValidationLabel: UILabel!
    
    @IBOutlet weak var genderButton: UIButton!
    
    var delegate: DynamicCellHeightDelegate?
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        self.setNeedsLayout()
    ////        self.layoutIfNeeded()
    //    }
    
    func setupView() {
        for each in textFields {
            each.delegate = self
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        
        for each in [nameValidationLabel, phoneValidationLabel, emailValidationLabel, genderValidationLabel, ageValidationLabel] {
            each?.isHidden = true
        }
        
    }
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == primayGuestField {
            return NameValidator().validate(text)
        } else if textField == contactField {
            return MobileValidator().validate(text)
        } else if textField == emailField {
            return EmailValidator().validate(text)
            //        } else if textField == genderField {
            //            return PasswordValidator().validate(text)
            //        } else if textField == ageField {
            //            return PasswordValidator().retypeValidate(passwordField.text ?? "", text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == primayGuestField {
            nameValidationLabel.text = message
            nameValidationLabel.isHidden = valid
        } else if textField == contactField {
            phoneValidationLabel.text = message
            phoneValidationLabel.isHidden = valid
        } else if textField == emailField {
            emailValidationLabel.text = message
            emailValidationLabel.isHidden = valid
        } else if textField == ageField {
            ageValidationLabel.text = message
            ageValidationLabel.isHidden = valid
        }
        
        delegate?.updateHeight()
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == primayGuestField {
                if valid {
                    nameValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    nameValidationLabel.text = message
                }
            } else if each == contactField {
                if valid {
                    phoneValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    phoneValidationLabel.text = message
                }
            } else if each == emailField {
                if valid {
                    emailValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    emailValidationLabel.text = message
                }
            } else if each == ageField {
                if valid {
                    ageValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    ageValidationLabel.text = message
                }
            }
        }
        delegate?.updateHeight()
    }
    
}

class GuestFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var guestNameField: CustomTextField!
    @IBOutlet weak var genderField: CustomTextField!
    @IBOutlet weak var ageField: CustomTextField!
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var genderValidationLabel: UILabel!
    @IBOutlet weak var ageValidationLabel: UILabel!
    
    @IBOutlet weak var genderButton: UIButton!
    
    var delegate: DynamicCellHeightDelegate?
    
    
    func setupView() {
        for each in textFields {
            each.delegate = self
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        
        for each in [nameValidationLabel, genderValidationLabel, ageValidationLabel] {
            each?.isHidden = true
        }
    }
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == guestNameField {
            return NameValidator().validate(text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == guestNameField {
            nameValidationLabel.text = message
            nameValidationLabel.isHidden = valid
        } else if textField == ageField {
            ageValidationLabel.text = message
            ageValidationLabel.isHidden = valid
        }
        
        delegate?.updateHeight()
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == guestNameField {
                if valid {
                    nameValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    nameValidationLabel.text = message
                }
            } else if each == ageField {
                if valid {
                    ageValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    ageValidationLabel.text = message
                }
            }
        }
        delegate?.updateHeight()
    }
}

class RoomSelectionActionsCollectionViewCell: UICollectionViewCell {
    
    
}

