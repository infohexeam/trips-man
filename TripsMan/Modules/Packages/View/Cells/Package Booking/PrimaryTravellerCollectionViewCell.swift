//
//  PrimaryTravellerCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/03/23.
//

import UIKit

class PrimaryTravellerCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var primayTravellerField: CustomTextField!
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
    var cvcDelegate: CollectionViewCellDelegate?
    
    func setupView() {
        for each in textFields {
            each.delegate = self
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        }
        
        for each in [nameValidationLabel, phoneValidationLabel, emailValidationLabel, genderValidationLabel, ageValidationLabel] {
            each?.isHidden = true
        }
        
        let items = K.genders.map { UIAction(title: "\($0)", handler: genderHandler) }
        genderButton.menu = UIMenu(title: "", children: items)
        genderButton.showsMenuAsPrimaryAction = true
        
    }
    
    func genderHandler(action: UIAction) {
        genderField.text = action.title
        cvcDelegate?.collectionViewCell(valueChangedIn: genderField, delegatedFrom: self)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        print("value change: \(sender.text)")
        cvcDelegate?.collectionViewCell(valueChangedIn: sender, delegatedFrom: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let delegate = cvcDelegate {
            return delegate.collectionViewCell(textField: textField, shouldChangeCharactersIn: range, replacementString: string, delegatedFrom: self)
        }
        return true
    }
    
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == primayTravellerField {
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
        if textField == primayTravellerField {
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
            if each == primayTravellerField {
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
