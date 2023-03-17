//
//  DefaultFilterViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/03/23.
//

import UIKit
import GooglePlaces

class DefaultFilterViewController: UIViewController {
    
    @IBOutlet weak var locationField: CustomTextField!
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var roomAddButton: UIButton!
    @IBOutlet weak var roomMinusButton: UIButton!
    @IBOutlet weak var adultAddButton: UIButton!
    @IBOutlet weak var adultMinusButton: UIButton!
    @IBOutlet weak var childAddButton: UIButton!
    @IBOutlet weak var childMinusButton: UIButton!
    
    @IBOutlet weak var filterSearchButton: UIButton!
    @IBOutlet weak var filterClearButton: UIButton!
    
    var hotelFilters = HotelListingFilters()
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
        
        roomQty = K.defaultRoomCount
        adultQty = K.defaultAdultCount
        childQty = K.defaultChildCount
        
        checkinField.text = hotelFilters.checkin!.stringValue(format: "dd-MM-yyyy")
        checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
        locationField.text = hotelFilters.location?.name

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
        datePickerViewController.hotelFilters = hotelFilters
        if tag == 1 {
            datePickerViewController.minDate = Date()
        } else {
            datePickerViewController.minDate = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440)
        }
        datePickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(datePickerViewController, animated: true)

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
            
        case checkInButton:
            presentDatePicker(1)
            
        case checkOutButton:
            presentDatePicker(2)
            
        case roomAddButton, roomMinusButton, childAddButton, childMinusButton, adultAddButton, adultMinusButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            self.view.endEditing(true)
            delegate?.searchDidTapped(hotelFilters)
            self.dismiss(animated: false)
            
        case filterClearButton:
            self.dismiss(animated: false)
            
        default:
            break
        }
        
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
        } else {
            checkoutField.text = date.stringValue(format: "dd-MM-yyyy")
            hotelFilters.checkout = date
        }
    }
}

protocol DefaultFilterDelegate {
    func searchDidTapped(_ filters: HotelListingFilters?)
}
