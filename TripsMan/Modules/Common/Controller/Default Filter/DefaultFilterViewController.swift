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
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var cityField: CustomTextField!
    @IBOutlet weak var cityButton: UIButton!
    
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var checkinView: UIView!
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var checkoutView: UIView!
    @IBOutlet weak var checkoutField: CustomTextField!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var startDateField: CustomTextField!
    @IBOutlet weak var startDateButton: UIButton!
    
    @IBOutlet weak var counterMainView: UIView!
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
    var activityFilters = ActivityFilters()
    var meetupFilters = MeetupFilters()
    var delegate: DefaultFilterDelegate?
    var listType: ListType!
    
    var roomQty = 0 {
        didSet {
            roomLabel.text = roomQty.oneOrMany("Room")
            hotelFilters.roomCount = roomQty
        }
    }
    
    var adultQty = 0 {
        didSet {
            adultLabel.text = adultQty.oneOrMany("Adult")
            packageFilters.adult = adultQty
            hotelFilters.adult = adultQty
        }
    }
    
    var childQty = 0 {
        didSet {
            childLabel.text = childQty.oneOrMany("Child", suffix: "ren")
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
            cityView.isHidden = true
            startDateView.isHidden = true
            
            roomQty = hotelFilters.roomCount ?? K.defaultRoomCount
            adultQty = hotelFilters.adult ?? K.defaultAdultCount
            childQty = hotelFilters.child ?? K.defaultChildCount
            
            checkinField.text = hotelFilters.checkin!.stringValue(format: "dd-MM-yyyy")
            checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
            locationField.text = hotelFilters.location?.name
            
        } else if listType == .packages {
            locationView.isHidden = true
            cityView.isHidden = true
            checkinView.isHidden = true
            checkoutView.isHidden = true
            roomView.isHidden = true
            
            adultQty = packageFilters.adult ?? K.defaultAdultCount
            childQty = packageFilters.child ?? K.defaultChildCount
            startDateField.text = packageFilters.startDate?.stringValue(format: "dd-MM-yyyy")
            countryField.text = packageFilters.country?.name
        } else if listType == .activities {
            locationView.isHidden = true
            cityView.isHidden = true
            checkinView.isHidden = true
            checkoutView.isHidden = true
            counterMainView.isHidden = true
            
            startDateField.text = activityFilters.activityDate?.stringValue(format: "dd-MM-yyyy")
            countryField.text = activityFilters.country?.name
        } else if listType == .meetups {
            
            locationView.isHidden = true
            dateStack.isHidden = true
            counterMainView.isHidden = true
            
            countryField.text = meetupFilters.country?.name
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

        if tag == 1 {
            datePickerViewController.minDate = Date()
            datePickerViewController.hotelFilters = hotelFilters
        } else if tag == 2 {
            datePickerViewController.minDate = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440)
            datePickerViewController.hotelFilters = hotelFilters
        } else if tag == 3 {
            datePickerViewController.minDate = Date().adding(minutes: 1440)
        } else if tag == 4 {
            datePickerViewController.minDate = Date()
        }
                    
        datePickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(datePickerViewController, animated: true)

    }
    
    func presentCountryPicker(_ isCity: Bool = false) {
        let countryPickerVC = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryListingViewController") as! CountryListingViewController
        countryPickerVC.delegate = self
        countryPickerVC.listType = listType
        countryPickerVC.isCity = isCity
        if isCity {
            countryPickerVC.countryId = meetupFilters.country?.countryID
        }
        
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
            
        case cityButton:
            presentCountryPicker(true)
            
        case checkInButton:
            presentDatePicker(1)
            
        case checkOutButton:
            presentDatePicker(2)
            
        case startDateButton:
            if listType == .packages {
                presentDatePicker(3)
            } else if listType == .activities {
                presentDatePicker(4)
            }
            
        case roomAddButton, roomMinusButton, childAddButton, childMinusButton, adultAddButton, adultMinusButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            self.view.endEditing(true)
            if listType == .hotel {
                delegate?.searchDidTapped(hotelFilters)
            } else if listType == .packages {
                delegate?.searchDidTapped(packageFilters)
            } else if listType == .activities {
                delegate?.searchDidTapped(activityFilters)
            } else if listType == .meetups {
                delegate?.searchDidTapped(meetupFilters)
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
    func cityDidSelected(_ cityName: String) {
        meetupFilters.city = cityName
        cityField.text = cityName
    }
    
    func countryDidSelected(_ country: Country) {
        packageFilters.country = country
        activityFilters.country = country
        meetupFilters.country = country
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
    func datePickerDoneTapped(date: Date, tag: Int) {
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
        } else if tag == 4 {
            startDateField.text = date.stringValue(format: "dd-MM-yyyy")
            activityFilters.activityDate = date
        }
    }
}

protocol DefaultFilterDelegate {
    func searchDidTapped(_ hotelFilters: HotelListingFilters?)
    func searchDidTapped(_ packageFilters: PackageFilters?)
    func searchDidTapped(_ activityFilters: ActivityFilters?)
    func searchDidTapped(_ meetupFilter: MeetupFilters?)
}
