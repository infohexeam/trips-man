//
//  ProfileViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 20/10/22.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var customerCodeField: CustomTextField!
    @IBOutlet weak var customerNameField: CustomTextField!
    @IBOutlet weak var mobileField: CustomTextField!
    @IBOutlet weak var emailField: CustomTextField!
    @IBOutlet weak var address1Field: CustomTextField!
    @IBOutlet weak var address2Field: CustomTextField!
    @IBOutlet weak var cityField: CustomTextField!
    @IBOutlet weak var stateField: CustomTextField!
    @IBOutlet weak var countryField: CustomTextField!
    @IBOutlet weak var pincodeField: CustomTextField!
    @IBOutlet weak var genderField: CustomTextField!
    @IBOutlet weak var dobField: CustomTextField!
    
    @IBOutlet var textFields: [CustomTextField]!
    
    @IBOutlet weak var nameValidationLabel: UILabel!
    @IBOutlet weak var address1ValidationLabel: UILabel!
    @IBOutlet weak var address2ValidationLabel: UILabel!
    @IBOutlet weak var cityValidationLabel: UILabel!
    @IBOutlet weak var stateValidationLabel: UILabel!
    @IBOutlet weak var countryValidationLabel: UILabel!
    @IBOutlet weak var pincodeValidationLabel: UILabel!
    @IBOutlet weak var genderValidationLabel: UILabel!
    @IBOutlet weak var dobValidationLabel: UILabel!
    
    @IBOutlet weak var updateButton: DisableButton!
    
    //PickerContainer
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var listPickerContainer: UIView!
    
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var dobButton: UIButton!
    
    var countryArray = [Country]()
    let genderArray = ["Male", "Female"]
    
    var selectedCountry: Country! {
        didSet {
            print("\n\n\n selected country: \(selectedCountry)")
        }
    }
    var selectedGender = "Male"
    var selectedRow = 0
    var selectedImageURL = ""
    
    let parser = Parser()
    
    var profileData: Profile?
    
    var imagePicker: ImagePicker!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addMenuButton(with: "My Profile")
        if SessionManager.shared.getLoginDetails() == nil {
            tabBarDelegate?.switchTab(0)
            tabBarDelegate?.presentVC("toLogin")
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        for each in textFields {
            each.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
            each.delegate = self
        }
        
        if SessionManager.shared.getLoginDetails() != nil {
            getProfileDetails()
        }
        
        hideKeyboardOnTap()

    }
    
    func setupView() {
        //Hide Validation Labels
        for each in [nameValidationLabel, address1ValidationLabel, address2ValidationLabel, cityValidationLabel, stateValidationLabel, countryValidationLabel, pincodeValidationLabel, genderValidationLabel, dobValidationLabel] {
            each?.isHidden = true
        }
        
//        updateButton.isEnabled = false
        
        listPicker.delegate = self
        listPicker.dataSource = self
        pickerContainer.isHidden = true
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    func assignData() {
        if let data = profileData {
            customerCodeField.text = data.customerCode
            customerNameField.text = data.customerName
            mobileField.text = data.mobile
            emailField.text = data.email
            address1Field.text = data.address1
            address2Field.text = data.address2
            cityField.text = data.city
            stateField.text = data.state
            countryField.text = data.country
            pincodeField.text = data.pincode
            genderField.text = data.gender
            dobField.text = data.dob
        }
    }
    
}

//MARK: - IBActions
extension ProfileViewController {
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        dobField.text = datePicker.date.stringValue(format: "dd-MM-yyyy")
        pickerContainer.isHidden = true
    }
    
    @IBAction func listPickerDoneTapped(_ sender: UIBarButtonItem) {
        if listPicker.tag == 1 {
            selectedGender = genderArray[selectedRow]
            genderField.text = selectedGender
        } else {
            selectedCountry = countryArray[selectedRow]
            countryField.text = selectedCountry.name
        }
        pickerContainer.isHidden = true
    }
    
    @IBAction func outSidePickerTapped(_ sender: UIButton) {
        pickerContainer.isHidden = true
    }
    
    @IBAction func fieldActionTapped(_ sender: UIButton) {
        switch sender {
        case genderButton:
            listPicker.tag = 1
            listPicker.reloadAllComponents()
            if genderField.text != "" {
                let index = genderArray.firstIndex(of: genderField.text!) ?? 0
                listPicker.selectRow(index, inComponent: 0, animated: true)
                selectedRow = index
                selectedGender = genderArray[index]
            } else {
                selectedRow = 0
            }
            listPickerContainer.isHidden = false
            datePickerContainer.isHidden = true
            
        case countryButton:
            if countryArray.count != 0 {
                listPicker.tag = 2
                listPicker.reloadAllComponents()
                if countryField.text != "" {
                    let countryNames = countryArray.map { $0.name}
                    let index = countryNames.firstIndex(of: countryField.text!) ?? 0
                    listPicker.selectRow(index, inComponent: 0, animated: true)
                    selectedRow = index
                    selectedCountry = countryArray[index]
                } else {
                    selectedRow = 0
                }
                listPickerContainer.isHidden = false
                datePickerContainer.isHidden = true
            } else {
                getCountryList()
            }
        case dobButton:
            listPickerContainer.isHidden = true
            datePickerContainer.isHidden = false
            datePicker.minimumDate = Date()
        default:
            break
        }
        pickerContainer.isHidden = false
    }
    
    @IBAction func profilePictureDidTapped(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
}

//MARK: - APICalls
extension ProfileViewController {
    func getProfileDetails() {
        showIndicator()
        
        print(SessionManager.shared.getLoginDetails()?.userid)
        print(SessionManager.shared.getLoginDetails()?.token)

        parser.sendRequestLoggedIn(url: "api/CustomerProfile/GetCustomerProfile?UserId=\(SessionManager.shared.getLoginDetails()?.userid ?? "")", http: .get, parameters: nil) { (result: ProfileData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.profileData = result!.data
                        self.assignData()
                        self.getCountryList()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    func getCountryList() {
        showIndicator()
        
        parser.sendRequestLoggedIn(url: "api/Country/GetCountryList", http: .get, parameters: nil) { (result: CountryData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.countryArray = result!.data
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    func uploadImage(imgData: Data) {
        showIndicator()
        
        let url = baseURL + "api/FileUpload/FTPUpload"
        print(url)
        
        let params = ["type_name": "customer"]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + (SessionManager.shared.getLoginDetails()?.token ?? "")
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imgData, withName: "file", fileName: "profile.png", mimeType: "image/png")
            
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url, method: .post, headers: headers).responseDecodable(of: ImageUploadData.self) { (response) in
            self.hideIndicator()
            if response.error == nil {
                if response.value!.status == 1 {
                    self.selectedImageURL = response.value!.data.url
                } else {
                    self.view.makeToast(response.value!.message)
                }
            } else {
                self.view.makeToast("Something went wrong!")
            }
            
        }
    }
}

//MARK: UITextField
extension ProfileViewController {
    fileprivate func validate(_ textField: UITextField) -> (Bool, String?) {
        guard let text = textField.text else {
            return (false, nil)
        }
        
        if text.count == 0 {
            return (false, "This field cannot be empty.")
        }
        
        if textField == customerNameField {
            return NameValidator().validate(text)
        }
        
        return (true, nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let (valid, message) = validate(textField)
        if textField == customerNameField {
            nameValidationLabel.text = message
            nameValidationLabel.isHidden = valid
//        } else if textField == address1Field {
//            address1ValidationLabel.text = message
//            address1ValidationLabel.isHidden = valid
//        } else if textField == address2Field {
//            address2ValidationLabel.text = message
//            address2ValidationLabel.isHidden = valid
//        } else if textField == cityField {
//            cityValidationLabel.text = message
//            cityValidationLabel.isHidden = valid
//        } else if textField == stateField {
//            stateValidationLabel.text = message
//            stateValidationLabel.isHidden = valid
//        } else if textField == countryField {
//            countryValidationLabel.text = message
//            countryValidationLabel.isHidden = valid
//        } else if textField == pincodeField {
//            pincodeValidationLabel.text = message
//            pincodeValidationLabel.isHidden = valid
        }
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        var isFormValid = true
        for each in textFields {
            let (valid, message) = validate(each)
            if each == customerNameField {
                if valid {
                    nameValidationLabel.isHidden = true
                } else {
                    isFormValid = false
                    nameValidationLabel.text = message
                }
//            } else if each == address1Field {
//                if valid {
//                    address1ValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    address1ValidationLabel.text = message
//                }
//            } else if each == address2Field {
//                if valid {
//                    address2ValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    address2ValidationLabel.text = message
//                }
//            } else if each == cityField {
//                if valid {
//                    cityValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    cityValidationLabel.text = message
//                }
//            } else if each == stateField {
//                if valid {
//                    stateValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    stateValidationLabel.text = message
//                }
//            }  else if each == countryField {
//                if valid {
//                    countryValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    countryValidationLabel.text = message
//                }
//            }  else if each == pincodeField {
//                if valid {
//                    pincodeValidationLabel.isHidden = true
//                } else {
//                    isFormValid = false
//                    pincodeValidationLabel.text = message
//                }
            }
        }
//        updateButton.isEnabled = isFormValid
    }
}


//PickerView
extension ProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return genderArray.count
        } else {
            return countryArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return genderArray[row]
        }
        return countryArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}

//MARK: - ImagePicker
extension ProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?, from sourceView: UIView, imageName: String) {
        print("selected \(imageName)")
        if let image = image {
            print("image picked \(imageName)")
            let imgData = image.jpegData(compressionQuality: 0.2)!
            profileImage.image = image
            uploadImage(imgData: imgData)
        }
    }
}



