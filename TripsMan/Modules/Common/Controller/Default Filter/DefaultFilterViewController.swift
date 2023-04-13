//
//  DefaultFilterViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/03/23.
//

import UIKit
import GooglePlaces

class DefaultFilterViewController: UIViewController {
    
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationField: CustomTextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var countryView: UIView!
    @IBOutlet weak var countryField: CustomTextField!
    @IBOutlet weak var countryButton: UIButton!
    
    @IBOutlet weak var checkinView: UIView!
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var checkoutView: UIView!
    @IBOutlet weak var checkoutField: CustomTextField!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var startDateField: CustomTextField!
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var roomView: UIView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var roomAddButton: UIButton!
    @IBOutlet weak var roomMinusButton: UIButton!
    @IBOutlet weak var adultView: UIView!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var adultAddButton: UIButton!
    @IBOutlet weak var adultMinusButton: UIButton!
    @IBOutlet weak var childView: UIView!
    @IBOutlet weak var childLabel: UILabel!
    @IBOutlet weak var childAddButton: UIButton!
    @IBOutlet weak var childMinusButton: UIButton!
    
    @IBOutlet weak var filterSearchButton: UIButton!
    @IBOutlet weak var filterClearButton: UIButton!
    
    var hotelFilters = HotelListingFilters()
    var packageFilters = PackageFilters()
    var delegate: DefaultFilterDelegate?
    var listType: ListType!
    
    var roomQty = 0 {
        didSet {
            if roomQty == 1 {
                roomLabel.text = "\(roomQty) Room"
            } else {
                roomLabel.text = "\(roomQty) Rooms"
            }
            hotelFilters.roomCount = roomQty
        }
    }
    
    var adultQty = 0 {
        didSet {
            if adultQty == 1 {
                adultLabel.text = "\(adultQty) Adult"
            } else {
                adultLabel.text = "\(adultQty) Adults"
            }
            packageFilters.adult = adultQty
            hotelFilters.adult = adultQty
        }
    }
    
    var childQty = 0 {
        didSet {
            if childQty == 1 {
                childLabel.text = "\(childQty) Child"
            } else {
                childLabel.text = "\(childQty) Children"
            }
            packageFilters.child = childQty
            hotelFilters.child = childQty
        }
    }
    
    private var placesClient: GMSPlacesClient!


    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
    }
    
    func setupView() {
        
        placesClient = GMSPlacesClient.shared()
        
        if listType == .hotel {
            countryView.isHidden = true
            startDateView.isHidden = true
            
            roomQty = K.defaultRoomCount
            adultQty = K.defaultAdultCount
            childQty = K.defaultChildCount
            
            checkinField.text = hotelFilters.checkin!.stringValue(format: "dd-MM-yyyy")
            checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
            locationField.text = hotelFilters.location?.name
            
        } else if listType == .packages {
            locationView.isHidden = true
            checkinView.isHidden = true
            checkoutView.isHidden = true
            roomView.isHidden = true
            
            adultQty = K.defaultAdultCount
            childQty = K.defaultChildCount
            startDateField.text = packageFilters.startDate?.stringValue(format: "dd-MM-yyyy")
            countryField.text = packageFilters.country?.name
        }
    }
    
    func presentGMSAutoCompleteVC() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue) |
                                                  UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.countries = ["IND"]
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func presentDatePicker(_ tag: Int) {
        let datePickerViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController

        datePickerViewController.pickerTag = tag
        datePickerViewController.delegate = self
        datePickerViewController.viewController = self

        if tag == 1 {
            datePickerViewController.minDate = Date()
            datePickerViewController.hotelFilters = hotelFilters
        } else if tag == 2 {
            datePickerViewController.minDate = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440)
            datePickerViewController.hotelFilters = hotelFilters
        } else if tag == 3 {
            datePickerViewController.minDate = Date().adding(minutes: 1440)
        }
        datePickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(datePickerViewController, animated: true)

    }
    
    func presentCountryPicker() {
        let countryPickerVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryListingViewController") as! CountryListingViewController
        countryPickerVC.delegate = self
        
        present(countryPickerVC, animated: true)
    }
    
    
    func addOrMinusPeople(_ sender: UIButton) {
        if sender == roomAddButton {
            roomQty += 1
            if adultQty < roomQty {
                adultQty = roomQty
            }
        } else if sender == roomMinusButton {
            if roomQty > 1 {
                roomQty -= 1
            }
        } else if sender == adultAddButton {
            adultQty += 1
        } else if sender == adultMinusButton {
            if adultQty > 1 && adultQty > roomQty {
                adultQty -= 1
            }
        } else if sender == childAddButton {
            childQty += 1
        } else if sender == childMinusButton {
            if childQty > 0 {
                childQty -= 1
            }
        }
    }

    
    @IBAction func outsideViewClicked(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func filterActionsClicked(_ sender: UIButton) {
        
        switch sender {
        case locationButton:
            presentGMSAutoCompleteVC()
            
        case countryButton:
            presentCountryPicker()
            
        case checkInButton:
            presentDatePicker(1)
            
        case checkOutButton:
            presentDatePicker(2)
            
        case startDateButton:
            presentDatePicker(3)
            
        case roomAddButton, roomMinusButton, childAddButton, childMinusButton, adultAddButton, adultMinusButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            self.view.endEditing(true)
            if listType == .hotel {
                delegate?.searchDidTapped(hotelFilters)
            } else if listType == .packages {
                delegate?.searchDidTapped(packageFilters)
            }
            self.dismiss(animated: false)
            
        case filterClearButton:
            self.dismiss(animated: false)
            
        default:
            break
        }
        
    }

}

extension DefaultFilterViewController: CountryPickerDelegate {
    func countryDidSelected(_ country: Country) {
        packageFilters.country = country
        countryField.text = country.name
    }
}


extension DefaultFilterViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        hotelFilters.location = Location(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, name: place.name ?? "")
        locationField.text = place.name
        viewController.dismiss(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
extension DefaultFilterViewController: DatePickerDelegate {
    func datePickerDoneTapped(_ viewController: UIViewController?, date: Date, tag: Int) {
        if viewController == self {
            if tag == 1 {
                checkinField.text = date.stringValue(format: "dd-MM-yyyy")
                hotelFilters.checkin = date
                if hotelFilters.checkin!.adding(minutes: 30) >= hotelFilters.checkout! {
                    hotelFilters.checkout = hotelFilters.checkin!.adding(minutes: 1440)
                    checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
                }
            } else if tag == 2 {
                checkoutField.text = date.stringValue(format: "dd-MM-yyyy")
                hotelFilters.checkout = date
            } else if tag == 3 {
                startDateField.text = date.stringValue(format: "dd-MM-yyyy")
                packageFilters.startDate = date
            }
        }
    }
}

protocol DefaultFilterDelegate {
    func searchDidTapped(_ hotelFilters: HotelListingFilters?)
    func searchDidTapped(_ packageFilters: PackageFilters?)
}
