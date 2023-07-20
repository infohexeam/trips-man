//
//  PrimaryTravellerCollectionViewCell.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 28/03/23.
//

import UIKit

class PrimaryTravellerCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    @IBOutlet weak var primayTravellerField: CustomTextField!
    @IBOutlet weak var countryCodeField: CustomTextField!
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
    @IBOutlet weak var countryCodeButton: UIButton!

    
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
        
        let codes = K.countryCodes.map { UIAction(title: "\($0.code)", handler: countryCodeHandler) }
        countryCodeButton.menu = UIMenu(title: "", children: codes)
        countryCodeButton.showsMenuAsPrimaryAction = true
    }
    
    func countryCodeHandler(action: UIAction) {
        countryCodeField.text = action.title
        cvcDelegate?.collectionViewCell(valueChangedIn: countryCodeField, delegatedFrom: self)
        if contactField.text?.count ?? 0 > K.countryCodes.filter( { $0.code == countryCodeField.text }).last?.mobileLength ?? 0 {
            contactField.text?.removeLast()
        }
    }
    
    func genderHandler(action: UIAction) {
        genderField.text = action.title
        cvcDelegate?.collectionViewCell(valueChangedIn: genderField, delegatedFrom: self)
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        cvcDelegate?.collectionViewCell(valueChangedIn: sender, delegatedFrom: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == contactField {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= K.countryCodes.filter( { $0.code == countryCodeField.text }).last?.mobileLength ?? 10
        }
        if textField == ageField {
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= 2
        }
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
            return (false, Validation.emptyFieldMessage)
        }
        
        if textField == primayTravellerField {
            return NameValidator().validate(text)
        } else if textField == contactField {
            return MobileValidator().validate(text)
        } else if textField == emailField {
            return EmailValidator().validate(text)
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
