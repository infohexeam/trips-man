//
//  HotelListingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/09/22.
//

import UIKit
import GooglePlaces


class HotelListingViewController: UIViewController {
    
    //FilterContainer
    @IBOutlet weak var filterContainer: UIView!
    
    @IBOutlet weak var locationField: CustomTextField!
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!

    @IBOutlet weak var hotelTypeField: CustomTextField!
    @IBOutlet weak var rateFromField: CustomTextField!
    @IBOutlet weak var rateToField: CustomTextField!
    
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
    
    //PickerContainer
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var listPickerContainer: UIView!
    
    
    //MainView
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateAndGuestLabel: UILabel!
    
    @IBOutlet weak var tripTypeField: CustomTextField!
    @IBOutlet weak var filterByField: CustomTextField!
    @IBOutlet weak var sortByField: CustomTextField!
    
    @IBOutlet weak var editFilterButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tripTypeButton: UIButton!
    @IBOutlet weak var filterByButton: UIButton!
    @IBOutlet weak var sortByButton: UIButton!
    
    
    
    @IBOutlet weak var hotelCollectionView: UICollectionView! {
        didSet {
            hotelCollectionView.collectionViewLayout = createLayout()
            hotelCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hotelCollectionView.dataSource = self
            hotelCollectionView.delegate = self
        }
    }
    
    
    enum SectionTypes {
        case hotelList
        case banner
    }
    
    struct HotelListSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [HotelListSection]? = nil
    var listingFilters = ListingFilters()
    
    var roomQty = 0 {
        didSet {
            if roomQty == 1 {
                roomLabel.text = "\(roomQty) Room"
            } else {
                roomLabel.text = "\(roomQty) Rooms"
            }
            listingFilters.room = roomQty
        }
    }
    
    var adultQty = 0 {
        didSet {
            if adultQty == 1 {
                adultLabel.text = "\(adultQty) Adult"
            } else {
                adultLabel.text = "\(adultQty) Adults"
            }
            listingFilters.adult = adultQty
        }
    }
    
    var childQty = 0 {
        didSet {
            if childQty == 1 {
                childLabel.text = "\(childQty) Child"
            } else {
                childLabel.text = "\(childQty) Children"
            }
            listingFilters.child = childQty
        }
    }
    
    private var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    var fontSize: CGFloat? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Hotels")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func setupView() {
        
        listPicker.delegate = self
        listPicker.dataSource = self
        
        filterContainer.isHidden = true
        pickerContainer.isHidden = true
        sections = [HotelListSection(type: .hotelList, count: 4),
                    HotelListSection(type: .banner, count: 2)]
        
        roomQty = 1
        adultQty = 2
        childQty = 0
        
        placesClient = GMSPlacesClient.shared()
        
        listingFilters.checkin = Date()
        listingFilters.checkout = Date().adding(minutes: 1440)
        checkinField.text = listingFilters.checkin!.stringValue(format: "dd-MM-yyyy")
        checkoutField.text = listingFilters.checkout!.stringValue(format: "dd-MM-yyyy")
        
        listingFilters.location = "Calicut"
        locationField.text = listingFilters.location
        
        assignValues()
        
    }
    
    func assignValues() {
        locationLabel.text = listingFilters.location
        let dateText = "\(listingFilters.checkin!.stringValue(format: "dd MMM")) - \(listingFilters.checkout!.stringValue(format: "dd MMM"))"
        var roomText = "\(listingFilters.room!) Rooms"
        if listingFilters.room == 1 {
            roomText = "\(listingFilters.room!) Room"
        }
        let guests = listingFilters.adult! + listingFilters.child!
        var guestText = "\(guests) Guests"
        if guests == 1 {
            guestText = "\(guests) Guest"
        }
        
        dateAndGuestLabel.text = dateText + " | " + roomText + " | " + guestText
    }
    
    func clearFields() {
        filterContainer.isHidden = true
    }
    
    func getCurrentLocation() {
        let placeFields: GMSPlaceField = [.name, .formattedAddress]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                
                guard error == nil else {
                    print("Current place error: \(error?.localizedDescription ?? "")")
                    return
                }
                
                guard let place = placeLikelihoods?.first?.place else {
//                    strongSelf.locationField.text = ""
                    return
                }
                
                strongSelf.locationField.text = (place.name ?? "")
                strongSelf.locationLabel.text = (place.name ?? "")
                strongSelf.listingFilters.location = (place.name ?? "")
            }
        }
    }
    
    func addOrMinusPeople(_ sender: UIButton) {
        if sender == roomAddButton {
            roomQty += 1
        } else if sender == roomMinusButton {
            if roomQty > 1 {
                roomQty -= 1
            }
        } else if sender == adultAddButton {
            adultQty += 1
        } else if sender == adultMinusButton {
            if adultQty > 1 {
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
    
    func presentGMSAutoCompleteVC() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.countries = ["IND"]
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

//MARK: - IBActions
extension HotelListingViewController {
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        if datePicker.tag == 1 {
            listingFilters.checkin = datePicker.date
            checkinField.text = listingFilters.checkin!.stringValue(format: "dd-MM-yyyy")
            if listingFilters.checkin! >= listingFilters.checkout! {
                listingFilters.checkout = listingFilters.checkin!.adding(minutes: 1440)
                checkoutField.text = listingFilters.checkout!.stringValue(format: "dd-MM-yyyy")
            }
        } else if datePicker.tag == 2 {
            listingFilters.checkout = datePicker.date
            checkoutField.text = listingFilters.checkout!.stringValue(format: "dd-MM-yyyy")
        }
        pickerContainer.isHidden = true
    }
    
    @IBAction func listPickerDoneTapped(_ sender: UIBarButtonItem) {
        pickerContainer.isHidden = true
    }
    
    @IBAction func outSideFilterClicked(_ sender: UIButton) {
        filterContainer.isHidden = true
        pickerContainer.isHidden = true
    }

    
    @IBAction func listingActionsClicked(_ sender: UIButton) {
        
        switch sender {
        case editFilterButton:
            filterContainer.isHidden = false
            
        case searchButton:
            return
            
        case tripTypeButton:
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = true
            listPickerContainer.isHidden = false
            
        case filterByButton:
            return
            
        case sortByButton:
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = true
            listPickerContainer.isHidden = false
            
            
        case locationButton:
            presentGMSAutoCompleteVC()
            
        case checkInButton:
            datePicker.tag = 1
            datePicker.minimumDate = Date()
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = false
            listPickerContainer.isHidden = true
            
        case checkOutButton:
            datePicker.tag = 2
            datePicker.minimumDate = listingFilters.checkin?.adding(minutes: 1440)
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = false
            listPickerContainer.isHidden = true
            
        case roomAddButton, roomMinusButton, childAddButton, childMinusButton, adultAddButton, adultMinusButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            self.view.endEditing(true)
            filterContainer.isHidden = true
            assignValues()
            
        case filterClearButton:
            clearFields()
            
            
        default:
            return
        }
        
    }
    
}

//MARK: - Location
extension HotelListingViewController : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
            getCurrentLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension HotelListingViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      listingFilters.location = place.name
      locationField.text = place.name
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
      
//    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}



//MARK: - UICollectionView
extension HotelListingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .hotelList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotelListCell", for: indexPath) as! HotelListCollectionViewCell
            if fontSize == nil {
                fontSize = cell.priceLabel.font.pointSize
            }
            cell.priceLabel.addPriceString("3999", "1999", fontSize: fontSize!)
            
            
            return cell
        } else if thisSection.type == .banner {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotelAdCell", for: indexPath) as! HotelListAdCollectionViewCell
            
            
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension HotelListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .hotelList {
            performSegue(withIdentifier: "toHotelDetails", sender: nil)
        }
    }
}

extension HotelListingViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .hotelList {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                  heightDimension: .fractionalWidth(containerWidth > 500 ? 0.3 : 0.6)),
                                                               subitem: item,
                                                               count: containerWidth > 500 ? 4 : 2)
                group.interItemSpacing = .fixed(10)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 20, trailing: 8)
                
            } else if thisSection.type == .banner {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

//PickerView
extension HotelListingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Test List \(row+1)"
    }
    
}
