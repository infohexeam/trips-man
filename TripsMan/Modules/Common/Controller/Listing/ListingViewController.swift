//
//  HotelListingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/09/22.
//

import UIKit
import GooglePlaces


class ListingViewController: UIViewController {
    
    //FilterContainer
    @IBOutlet weak var filterContainer: UIView!
    @IBOutlet weak var filterInnerView: UIView!
    
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
    
   
    var listType: ListType?
    var pageTitle: String?
    
    var hotelFilters = HotelListingFilters()
    
    let parser = Parser()
    var filters = [Filte]()
    var sorts = [Sortby]()
    var tripTypes = [TripType]()
    
    var selectedFilterIndexes = [IndexPath]()
    
    var timer: Timer?
    
    var listingManager = ListingManager()
    
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
    let locationManager = CLLocationManager()
    
    var fontSize: CGFloat? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch listType {
        case .hotel:
            pageTitle = "Hotels"
        case .packages:
            pageTitle = "Packages"
        case .meetups:
            pageTitle = "Meetups"
        case .activities:
            pageTitle = "Activities"
        case .none:
            pageTitle = ""
        }
        addBackButton(with: pageTitle ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        locationManager.delegate = self
        //        locationManagerDidChangeAuthorization(locationManager)
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        //        locationManager.startUpdatingLocation()
        
        
        if listType == .hotel {
            getHotels()
        } else if listType == .packages {
            getPackages()
        }
        
    }
    
    func setupView() {
        
        listPicker.delegate = self
        listPicker.dataSource = self
        
        filterContainer.isHidden = true
        pickerContainer.isHidden = true
        
        roomQty = 1
        adultQty = 2
        childQty = 0
        
        placesClient = GMSPlacesClient.shared()
        
        hotelFilters.checkin = Date()
        hotelFilters.checkout = Date().adding(minutes: 1440)
        checkinField.text = hotelFilters.checkin!.stringValue(format: "dd-MM-yyyy")
        checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
        
        hotelFilters.location = Location(latitude: 11.259698798029197, longitude: 75.82969398017917, name: "Calicut")
        locationField.text = hotelFilters.location?.name
        
        hotelFilters.rate = Rate(from: Int(K.minimumPrice), to: Int(K.maximumPrice))
        
        assignValues()
        
    }
    
    func assignValues() {
        locationLabel.text = hotelFilters.location?.name
        let dateText = "\(hotelFilters.checkin!.stringValue(format: "dd MMM")) - \(hotelFilters.checkout!.stringValue(format: "dd MMM"))"
        var roomText = "\(hotelFilters.roomCount!) Rooms"
        if hotelFilters.roomCount == 1 {
            roomText = "\(hotelFilters.roomCount!) Room"
        }
        let guests = hotelFilters.adult! + hotelFilters.child!
        var guestText = "\(guests) Guests"
        if guests == 1 {
            guestText = "\(guests) Guest"
        }
        
        dateAndGuestLabel.text = dateText + " | " + roomText + " | " + guestText
    }
    
    func setupMenus() {
        let tripTypes = tripTypes.map { UIAction(title: "\($0.name)", state: $0.name == hotelFilters.tripType?.name ? .on : .off, handler: tripTypeHandler) }
        tripTypeButton.menu = UIMenu(title: "", children: tripTypes)
        tripTypeButton.showsMenuAsPrimaryAction = true
        
        let sorts = sorts.map { UIAction(title: "\($0.name)", handler: sortHandler) }
        sortByButton.menu = UIMenu(title: "", children: sorts)
        sortByButton.showsMenuAsPrimaryAction = true
    }
    
    func tripTypeHandler(action: UIAction) {
        if hotelFilters.tripType?.name == action.title {
            hotelFilters.tripType = nil
        } else {
            hotelFilters.tripType = tripTypes.filter { $0.name == action.title }.last
        }
        setupMenus()
        getHotels()
    }
    
    func sortHandler(action: UIAction) {
        hotelFilters.sort = sorts.filter { $0.name == action.title }.last
        getHotels()
    }
    
    func clearFields() {
        filterContainer.isHidden = true
        //        let slideUpViewHeight: CGFloat = 200
        //        let screenSize = UIScreen.main.bounds.size
        //
        //        UIView.animate(withDuration: 0.5,
        //                         delay: 0, usingSpringWithDamping: 1.0,
        //                         initialSpringVelocity: 1.0,
        //                         options: .curveEaseInOut, animations: {
        //            self.filterInnerView.frame = CGRect(x: 0, y: slideUpViewHeight, width: screenSize.width, height: 0)
        ////            self.filterContainer.isHidden = true
        //            self.filterContainer.isHidden = true
        //
        //          }, completion: nil)
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
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? FilterViewController {
                vc.filters = filters
                vc.delegate = self
                vc.selectedIndexes = selectedFilterIndexes
                vc.selectedRates = hotelFilters.rate
            }
        } else if let vc = segue.destination as? HotelDetailsViewController {
            if let index = sender as? Int {
                vc.hotelID = listingManager.getListingData()?[index].id ?? 0
                vc.hotelFilters = hotelFilters
            } else if let selHotel = sender as? Hotel {
                vc.hotelID = selHotel.hotelID
                vc.hotelFilters = hotelFilters
            }
        } else if let vc = segue.destination as? SearchViewController {
            vc.delegate = self
        }
    }
    
    
}

extension ListingViewController: SearchDelegate {
    func searchItemDidPressed(_ item: Hotel) {
        performSegue(withIdentifier: "toHotelDetails", sender: item)
    }
}

//MARK: - IBActions
extension ListingViewController {
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        if datePicker.tag == 1 {
            hotelFilters.checkin = datePicker.date
            checkinField.text = hotelFilters.checkin!.stringValue(format: "dd-MM-yyyy")
            if hotelFilters.checkin! >= hotelFilters.checkout! {
                hotelFilters.checkout = hotelFilters.checkin!.adding(minutes: 1440)
                checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
            }
        } else if datePicker.tag == 2 {
            hotelFilters.checkout = datePicker.date
            checkoutField.text = hotelFilters.checkout!.stringValue(format: "dd-MM-yyyy")
        }
        pickerContainer.isHidden = true
    }
    
    @IBAction func listPickerDoneTapped(_ sender: UIBarButtonItem) {
        pickerContainer.isHidden = true
    }
    
    @IBAction func outSideFilterClicked(_ sender: UIButton) {
        clearFields()
    }
    
    @IBAction func outSidePickerClicked(_ sender: UIButton) {
        pickerContainer.isHidden = true
    }
    
    @IBAction func listingActionsClicked(_ sender: UIButton) {
        
        switch sender {
        case editFilterButton:
            
            let slideUpViewHeight: CGFloat = 200
            let screenSize = UIScreen.main.bounds.size
            
            UIView.animate(withDuration: 0.5,
                           delay: 0, usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseInOut, animations: {
                self.filterInnerView.frame = CGRect(x: 0, y: screenSize.height - slideUpViewHeight, width: screenSize.width, height: slideUpViewHeight)
                self.filterContainer.isHidden = false
                
            }, completion: nil)
            
            
        case searchButton:
            performSegue(withIdentifier: "toSearch", sender: nil)
            
        case tripTypeButton:
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = true
            listPickerContainer.isHidden = false
            
        case filterByButton:
            if filters.count != 0 {
                performSegue(withIdentifier: "toFilter", sender: nil)
            } else {
                getFilters()
            }
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
            datePicker.minimumDate = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440)
            pickerContainer.isHidden = false
            datePickerContainer.isHidden = false
            listPickerContainer.isHidden = true
            
        case roomAddButton, roomMinusButton, childAddButton, childMinusButton, adultAddButton, adultMinusButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            self.view.endEditing(true)
            filterContainer.isHidden = true
            assignValues()
            getHotels()
            
        case filterClearButton:
            clearFields()
            
        default:
            return
        }
        
    }
    
//    @IBAction func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        print("long")
//        if let sender = gesture.view as? UIButton {
//            if gesture.state == .began {
//                    timer?.invalidate()
//                    timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
//                        guard let self = self else {
//                            timer.invalidate()
//                            return
//                        }
//                        self.addOrMinusPeople(sender)
//                    }
//                } else if gesture.state == .ended || gesture.state == .cancelled {
//                    timer?.invalidate()
//                }
//        }
//    }
//
//    @IBAction func handleTap(_ gesture: UITapGestureRecognizer) {
//        print("tap")
//        if let sender = gesture.view as? UIButton {
//            addOrMinusPeople(sender)
//        }
//    }
//
    
}

//MARK: - APICalls
extension ListingViewController {
    func getFilters() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHoteFilterlList?Language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: FilterResp?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.filters = result!.data.filtes
                        self.sorts = result!.data.sortby
                        self.tripTypes = result!.data.tripTypes
                        self.setupMenus()
                        self.getBanners()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getHotels() {
        showIndicator()
        
        var params: [String: Any] = ["CheckInDate": hotelFilters.checkin!.stringValue(format: "yyyy/MM/dd"),
                                     "CheckOutDate": hotelFilters.checkout!.stringValue(format: "yyyy/MM/dd"),
                                     "AdultCount": hotelFilters.adult!,
                                     "ChildCount": hotelFilters.child!,
                                     "RoomCount": hotelFilters.roomCount!,
                                     "latitude": hotelFilters.location!.latitude,
                                     "longitude": hotelFilters.location!.longitude,
                                     "Country": SessionManager.shared.getCountry(),
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage(),
                                     "HotelRateFrom": hotelFilters.rate!.from,
                                     "HotelRateTo": hotelFilters.rate!.to,
                                     "HotelFilters": hotelFilters.filters ?? [String: [Any]](),
                                     "SortBy": ""]
        
        if let sort = hotelFilters.sort {
            params["SortBy"] = sort.name
        }
        
        if let tripType = hotelFilters.tripType {
            params["tripType"] = tripType.id
        }
        
        print("\n\n listingParms: \(params)")
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHotelList", http: .post, parameters: params) { (result: HotelData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignHotels(hotels: result!.data)
                        self.hotelCollectionView.reloadData()
                        if self.filters.count == 0 {
                            self.getFilters()
                        }
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    
    func getPackages() {
        showIndicator()
        
        var params: [String: Any] = ["package_types": [],
                                     "sortBy": "",
                                     "offset": 0,
                                     "recordCount": 0,
                                     "Country": SessionManager.shared.getCountry(),
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage(),
                                     "SortBy": ""]
        
//        if let sort = hotelFilters.sort {
//            params["SortBy"] = sort.name
//        }
//
//        if let tripType = hotelFilters.tripType {
//            params["tripType"] = tripType.id
//        }
        
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHoliday/GetCustomerHolidayPackageList", http: .post, parameters: params) { (result: PackageListingData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignPackages(packages: result!.data)
                        self.hotelCollectionView.reloadData()
//                        if self.filters.count == 0 {
//                            self.getFilters()
//                        }
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    
    
    func getBanners() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerBanner/GetCustomerBannerList?Type=hotel_list", http: .get, parameters: nil) { (result: BannerData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignBanners(banners: result!.data)
                        self.hotelCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
}

//MARK: - Location
extension ListingViewController : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            DispatchQueue.main.async {
                self.locationManager.requestLocation()
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("location:: \(location)")
            locationManager.stopUpdatingLocation()
            getCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension ListingViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        hotelFilters.location = Location(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude, name: place.name ?? "")
        print("cordinates \(place.coordinate)")
        print("\n\nlocation2: \(hotelFilters.location)")
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
extension ListingViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listingManager.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.listingManager.getSections()?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = self.listingManager.getSections()?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotelListCell", for: indexPath) as! HotelListCollectionViewCell
            
            let index = indexPath.section == 0 ? indexPath.row : indexPath.row + 4
            
            if let data = listingManager.getListingData()?[index] {
                cell.listImage.sd_setImage(with: URL(string: data.listImage ?? ""), placeholderImage: UIImage(named: data.placeHolderImage))
                cell.sponsoredView.isHidden = data.isSponsored == 0
                
                cell.ratingMainView.isHidden = data.type != .hotel
                cell.starRating.text = data.starRatingText
                
                cell.userRatingView.isHidden = data.userRating?.ratingCount == 0
                cell.userRatingLabel.text = data.userRating?.rating
                cell.userRatingText.text = data.userRating?.ratingText
                
                cell.nameLabel.text = data.listName
                cell.secondLabel.text = data.secondText
                
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(data.actualPrice, data.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = data.taxLabelText
                
            }
            
            return cell
        } else if thisSection.type == .banner {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotelAdCell", for: indexPath) as! HotelListAdCollectionViewCell
            
            if let banner = listingManager.getBanners()?[indexPath.row] {
                cell.bannerImage.sd_setImage(with: URL(string: banner.url))
            }
            
            return cell
        } else if thisSection.type == .zeroData {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "zeroDataCell", for: indexPath)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension ListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = listingManager.getSections()?[indexPath.section] else { return }
        if thisSection.type == .list {
            var index = indexPath.row
            if indexPath.section != 0 {
                index = indexPath.row + 4
            }
            performSegue(withIdentifier: "toHotelDetails", sender: index)
        }
    }
}

extension ListingViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.listingManager.getSections()?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .list {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                  heightDimension: .estimated(10)),
                                                               subitem: item,
                                                               count: containerWidth > 500 ? 4 : 2)
                group.interItemSpacing = .fixed(8)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 20, trailing: 8)
                
            } else if thisSection.type == .banner {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(thisSection.count == 1 ? 0.95 : 0.9),
                                                       heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .zeroData {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalHeight(1.0))
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
extension ListingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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

extension ListingViewController: FilterDelegate {
    func filterSearchTapped(minimumPrice: Double, maximumPrice: Double, filterIndexes: [IndexPath]?) {
        hotelFilters.rate = Rate(from: Int(minimumPrice), to: Int(maximumPrice))
        var selectedFilters = [String: [Int]]()
        for filter in filters {
            selectedFilters[filter.filterKey] = []
        }
        if let filterIndexes = filterIndexes {
            for index in filterIndexes {
                selectedFilters[filters[index.section - 1].filterKey]?.append(filters[index.section - 1].values[index.row].id)
            }
            hotelFilters.filters = selectedFilters
            selectedFilterIndexes = filterIndexes
        }
        
        
        
        getHotels()
    }
}
