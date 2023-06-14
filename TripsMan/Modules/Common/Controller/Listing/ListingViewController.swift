//
//  HotelListingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/09/22.
//

import UIKit
import GooglePlaces


class ListingViewController: UIViewController {
    
    
    
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
    
    @IBOutlet weak var tripTypeMainView: UIView!
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var hotelCollectionView: UICollectionView! {
        didSet {
            hotelCollectionView.collectionViewLayout = createLayout()
            hotelCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hotelCollectionView.dataSource = self
            hotelCollectionView.delegate = self
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
            hotelCollectionView.refreshControl = refreshControl
        }
    }
    
   
    var listType: ListType?
    var pageTitle: String?
    
    var hotelFilters = HotelListingFilters()
    var packageFilter = PackageFilters()
    var activityFilter = ActivityFilters()
    var meetupFilter = MeetupFilters()
    
    let parser = Parser()
    var filters = [Filter]()
    var sorts = [Sortby]()
    var tripTypes = [TripType]()
    
    var selectedFilterIndexes = [IndexPath]()
    
    var timer: Timer?
    
    var listingManager = ListingManager()
    
    private var placesClient: GMSPlacesClient!
    
    let locationManager = CLLocationManager()
    
    var fontSize: CGFloat? = nil
    
    var currentOffset = 0
    var totalPages = 1
    let recordCount = 20
    var isLoading = false
    
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
        
        
        if let listType = listType {
            callListingAPI(of: listType)
        }
    }
    
    func setupView() {
        placesClient = GMSPlacesClient.shared()
        
        if listType == .hotel {
            hotelFilters.checkout = Date().adding(minutes: 1440)
            hotelFilters.checkin = Date()
            
            hotelFilters.roomCount = K.defaultRoomCount
            hotelFilters.adult = K.defaultAdultCount
            hotelFilters.child = K.defaultChildCount
            
            hotelFilters.rate = Rate(from: Int(K.minimumPrice), to: Int(K.maximumPrice))
        } else if listType == .packages {
            packageFilter.country = Country(countryID: 149, name: "India", code: "IND", icon: nil)
            packageFilter.adult = K.defaultAdultCount
            packageFilter.child = K.defaultChildCount
            packageFilter.rate = Rate(from: Int(K.minimumPrice), to: Int(K.maximumPrice))
            tripTypeMainView.isHidden = true
        } else if listType == .activities {
            tripTypeMainView.isHidden = true
            activityFilter.country = Country(countryID: 149, name: "India", code: "IND", icon: nil)
            activityFilter.rate = Rate(from: Int(K.minimumPrice), to: Int(K.maximumPrice))
        } else if listType == .meetups {
            tripTypeMainView.isHidden = true
            meetupFilter.country = Country(countryID: 149, name: "India", code: "IND", icon: nil)
            meetupFilter.rate = Rate(from: Int(K.minimumPrice), to: Int(K.maximumPrice))
        }
        
        assignValues()
        
    }
    
    func assignValues() {
        
        if listType == .hotel {
            locationLabel.text = hotelFilters.location?.name ?? "Select location"
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
        } else if listType == .packages {
            locationLabel.text = packageFilter.country?.name
            var dateText = packageFilter.startDate?.stringValue(format: "dd MMM")
            if dateText == nil {
                dateText = "Add start date"
                
            }
            let adultText = packageFilter.adult?.oneOrMany("Adult")
            
            var secondText = dateText! + " | " + adultText!
            
            if packageFilter.child != nil && packageFilter.child != 0 {
                let childText = packageFilter.child!.oneOrMany("Child", suffix: "ren")
                secondText = secondText + " | " + childText
            }
            dateAndGuestLabel.text = secondText
        } else if listType == .activities {
            locationLabel.text = activityFilter.country?.name
            var dateText = activityFilter.activityDate?.stringValue(format: "dd MMM")
            if dateText == nil {
                dateText = "Select date"
            }
            dateAndGuestLabel.text = dateText
        } else if listType == .meetups {
            var cityText = meetupFilter.city
            locationLabel.text = (meetupFilter.country?.name ?? "") + " | " + (cityText ?? "Select city")
            dateAndGuestLabel.isHidden = true
        }
        
        
    }
    
    func setupMenus() {
        let tripTypes = tripTypes.map { UIAction(title: "\($0.name)", state: $0.name == hotelFilters.tripType?.name ? .on : .off, handler: tripTypeHandler) }
        tripTypeButton.menu = UIMenu(title: "", children: tripTypes)
        tripTypeButton.showsMenuAsPrimaryAction = true
        
        
        
        let sorts = sorts.map { UIAction(title: "\($0.name)", state: $0.name == getSortName() ? .on: .off, handler: sortHandler) }
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
        callListingAPI(of: .hotel)
    }
    
    func sortHandler(action: UIAction) {
        assignSort(sorts.filter { $0.name == action.title }.last)
    }
    
    func getSortName() -> String? {
        var sortName: String?
        if listType == .hotel {
            sortName = hotelFilters.sort?.name
        } else if listType == .packages {
            sortName = packageFilter.sort?.name
        } else if listType == .activities {
            sortName = activityFilter.sort?.name
        } else if listType == .meetups {
            sortName = meetupFilter.sort?.name
        }
        
        return sortName
    }
    
    func assignSort(_ sort: Sortby?) {
        if let listType = listType {
            switch listType {
            case .hotel:
                hotelFilters.sort = sort
            case .packages:
                packageFilter.sort = sort
            case .activities:
                activityFilter.sort = sort
            case .meetups:
                meetupFilter.sort = sort
            }
            setupMenus()
            callListingAPI(of: listType)
        }
        
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
                
//                strongSelf.locationField.text = (place.name ?? "")
                if strongSelf.listType == .hotel {
                    strongSelf.locationLabel.text = (place.name ?? "")
                }
            }
        }
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        if let listType = listType {
            callListingAPI(of: listType)
        }
    }
    
    func callListingAPI(of type: ListType, isPagination: Bool = false) {
        switch type {
        case .hotel:
            getHotels(isPagination: isPagination)
        case .packages:
            getPackages()
        case .activities:
            getActivities()
        case .meetups:
            getMeetups()
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? FilterViewController {
                vc.filters = filters
                vc.delegate = self
                vc.selectedIndexes = selectedFilterIndexes
                if let listType = listType {
                    switch listType {
                    case .hotel:
                        vc.selectedRates = hotelFilters.rate
                    case .packages:
                        vc.selectedRates = packageFilter.rate
                    case .activities:
                        vc.selectedRates = activityFilter.rate
                    case .meetups:
                        vc.selectedRates = meetupFilter.rate
                    }
                }
                
            }
        } else if let vc = segue.destination as? HotelDetailsViewController {
            if let index = sender as? Int {
                vc.hotelID = listingManager.getListingData()?[index].id ?? 0
                vc.hotelFilters = hotelFilters
            } else if let selHotel = sender as? HotelSearch {
                vc.hotelID = selHotel.hotelID
                vc.hotelFilters = hotelFilters
            }
        } else if let vc = segue.destination as? SearchViewController {
            vc.delegate = self
            if listType == .hotel {
                vc.module = "HTL"
            } else if listType == .packages {
                vc.module = "HDY"
            } else if listType == .activities {
                vc.module = "ACT"
            } else if listType == .meetups {
                vc.module = "MTP"
            }
        } else if let vc = segue.destination  as? DefaultFilterViewController {
            vc.hotelFilters = hotelFilters
            vc.packageFilters = packageFilter
            vc.activityFilters = activityFilter
            vc.meetupFilters = meetupFilter
            vc.listType = listType
            vc.delegate = self
        } else if let vc = segue.destination as? PackageDetailsViewController {
            if let index = sender as? Int {
                vc.packageID = listingManager.getListingData()?[index].id ?? 0
                vc.packageFilters = packageFilter
            } else if let selPackage = sender as? HolidaySearch {
                vc.packageID = selPackage.packageID
                vc.packageFilters = packageFilter
            }
        } else if let vc = segue.destination as? ActivityDetailsViewController {
            if let index = sender as? Int {
                vc.activityID = listingManager.getListingData()?[index].id ?? 0
                vc.activityFilters = activityFilter
            } else if let selActivity = sender as? ActivitySearch {
                vc.activityID = selActivity.activityID
                vc.activityFilters = activityFilter
            }
        } else if let vc = segue.destination as? MeetupDetailsViewController {
            if let index = sender as? Int {
                vc.meetupID = listingManager.getListingData()?[index].id ?? 0
                vc.meetupFilters = meetupFilter
            } else if let selMeetup = sender as? MeetupSearch {
                vc.meetupID = selMeetup.meetupID
                vc.meetupFilters = meetupFilter
            }
        }
    }
    
    
}

extension ListingViewController: SearchDelegate {
    func searchItemDidPressed(_ item: Search, index: Int) {
        if let hotel = item.hotel {
            performSegue(withIdentifier: "toHotelDetails", sender: hotel[index])
        } else if let holiday = item.holiday {
            performSegue(withIdentifier: "toPackageDetails", sender: holiday[index])
        } else if let activities = item.activity {
            performSegue(withIdentifier: "toActivityDetails", sender: activities[index])
        } else if let meetups = item.meetup {
            performSegue(withIdentifier: "toMeetupDetails", sender: meetups[index])
        }
    }
}

extension ListingViewController: DefaultFilterDelegate {
    func searchDidTapped(_ meetupFilter: MeetupFilters?) {
        if let filters = meetupFilter {
            self.meetupFilter = filters
            assignValues()
            callListingAPI(of: .meetups)
        }
    }
    
    func searchDidTapped(_ activityFilters: ActivityFilters?) {
        if let filters = activityFilters {
            self.activityFilter = filters
            assignValues()
            callListingAPI(of: .activities)
        }
    }
    
    func searchDidTapped(_ packageFilters: PackageFilters?) {
        if let filters = packageFilters {
            self.packageFilter = filters
            assignValues()
            callListingAPI(of: .packages)
       }

    }
    
    func searchDidTapped(_ hotelFilters: HotelListingFilters?) {
        if let filters = hotelFilters {
            self.hotelFilters = filters
            assignValues()
            callListingAPI(of: .hotel)
        }
    }
    
}

//MARK: - IBActions
extension ListingViewController {
    
    @IBAction func listingActionsClicked(_ sender: UIButton) {
        
        switch sender {
        case editFilterButton:
            
            performSegue(withIdentifier: "toDefaultFilter", sender: nil)
            
        case searchButton:
            performSegue(withIdentifier: "toSearch", sender: nil)
            
        case filterByButton:
            if filters.count != 0 {
                performSegue(withIdentifier: "toFilter", sender: nil)
            } else {
                if listType == .hotel {
                    getFilters()
                } else if listType == .packages {
                    getPackageFilters()
                } else if listType == .activities {
                    getActivityFilters()
                } else if listType == .meetups {
                    getMeetupFilters()
                }
            }
            return
        default:
            return
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
                cell.userRatingText.isHidden = data.userRating?.ratingCount == 0
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "zeroDataCell", for: indexPath) as!NoDataCollectionViewCell
            if let listType = listType {
                cell.nodataLabel.text = listingManager.getNoDataString(of: listType)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let thisSection = self.listingManager.getSections()?[indexPath.section] else { return }
        if thisSection.type == .list {
            if indexPath.item == (listingManager.getListingData()?.count ?? 0) - 1, currentOffset < totalPages, isLoading == false {
                if let listType = listType {
                    //TODO: -
                    if listType == .hotel {
                        callListingAPI(of: listType, isPagination: true)
                    } else {
                        
                    }
                    

                }
            }
        }
        
    }
}

extension ListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = listingManager.getSections()?[indexPath.section] else { return }
        if thisSection.type == .list {
            if listType == .hotel {
                var index = indexPath.row
                if indexPath.section != 0 {
                    index = indexPath.row + 4
                }
                performSegue(withIdentifier: "toHotelDetails", sender: index)
            } else if listType == .packages {
                performSegue(withIdentifier: "toPackageDetails", sender: indexPath.row)
            } else if listType == .activities {
                performSegue(withIdentifier: "toActivityDetails", sender: indexPath.row)
            } else if listType == .meetups {
                performSegue(withIdentifier: "toMeetupDetails", sender: indexPath.row)
            }
            
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


extension ListingViewController: FilterDelegate {
    func filterSearchTapped(minimumPrice: Double, maximumPrice: Double, filterIndexes: [IndexPath]?) {
        
        var selectedFilters = [String: [Int]]()
        for filter in filters {
            selectedFilters[filter.filterKey] = []
        }
        if let filterIndexes = filterIndexes {
            for index in filterIndexes {
                selectedFilters[filters[index.section - 1].filterKey]?.append(filters[index.section - 1].values[index.row].id)
            }
            selectedFilterIndexes = filterIndexes
            
//            hotelFilters.filters = selectedFilters
//            hotelFilters.rate = Rate(from: Int(minimumPrice), to: Int(maximumPrice))
            assignFilters(filters: selectedFilters, rate: Rate(from: Int(minimumPrice), to: Int(maximumPrice)))

        }
    }
    
    func assignFilters(filters: [String: [Int]], rate: Rate) {
        if let listType = listType {
            switch listType {
            case .hotel:
                hotelFilters.filters = filters
                hotelFilters.rate = rate
            case .packages:
                packageFilter.filters = filters
                packageFilter.rate = rate
            case .activities:
                activityFilter.filters = filters
                activityFilter.rate = rate
            case .meetups:
                meetupFilter.filters = filters
                meetupFilter.rate = rate
            }
            callListingAPI(of: listType)
        }
    }
}
