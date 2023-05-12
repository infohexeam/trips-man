//
//  HotelDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 26/09/22.
//

import UIKit
import CoreLocation
import MapKit
import Combine

class HotelDetailsViewController: UIViewController {
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageContainer: UIView!
    
    
    //FilterContainer
    @IBOutlet weak var filterContainer: UIView!
    @IBOutlet weak var filterInnerView: UIView!
    
    @IBOutlet weak var locationField: CustomTextField!
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!
    
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
    
    @IBOutlet weak var filterOutsideButton: UIButton!
    
    var roomQty = 0 {
        didSet {
            roomLabel.text = roomQty.oneOrMany("Room")
        }
    }
    
    var adultQty = 0 {
        didSet {
            adultLabel.text = adultQty.oneOrMany("Adult")
        }
    }
    
    var childQty = 0 {
        didSet {
            childLabel.text = childQty.oneOrMany("Child", suffix: "ren")
        }
    }
    
    var fontSize: CGFloat? = nil
    var linesToShow = 3
    var termsLinesToShow = 3
    var facilityCount = 5
    
    var hotelID = 0
    
    var hotelFilters = HotelListingFilters()
    
    let parser = Parser()
    var hotelDetails: HotelDetails? {
        didSet {
            loadSection()
        }
    }
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    @IBOutlet weak var hotelDetailsCollectionView: UICollectionView! {
        didSet {
            hotelDetailsCollectionView.collectionViewLayout = createLayout()
            hotelDetailsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hotelDetailsCollectionView.dataSource = self
            hotelDetailsCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var imagesCollectionView: UICollectionView! {
        didSet {
            imagesCollectionView.collectionViewLayout = createImageLayout()
            imagesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imagesCollectionView.dataSource = self
            imagesCollectionView.delegate = self
        }
    }
    
    enum SectionTypes {
        case hotelImage
        case hotelDetails
        case hotelAddrress
        case facilities
        case seperator
        case roomFilter
        case rooms
        case rules
        case terms
        case rating
        case review
        case roomImage
    }
    
    struct DetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [DetailsSection]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Hotel Details")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerContainer.isHidden = true
        imageContainer.isHidden = true
        filterContainer.isHidden = true
        
        getHotelDetails()
        
    }
    
    func assignFilterData() {
        locationField.text = hotelDetails?.hotelName
        checkinField.text = hotelFilters.checkin?.stringValue(format: "dd-MM-yyyy")
        checkoutField.text = hotelFilters.checkout?.stringValue(format: "dd-MM-yyyy")
        roomLabel.text = hotelFilters.roomCount?.oneOrMany("Room")
        roomQty = hotelFilters.roomCount!
        childLabel.text = hotelFilters.child?.oneOrMany("Child", suffix: "ren")
        childQty = hotelFilters.child!
        adultLabel.text = hotelFilters.adult?.oneOrMany("Adult")
        adultQty = hotelFilters.adult!
    }
    
    func loadSection() {
        
        if let hotelDetails = hotelDetails {
            let filtReview = hotelDetails.hotelReviews.filter { $0.hotelReview != "" }
            var reviewSectionCount = 0
            if filtReview.count != 0 {
                reviewSectionCount = filtReview.count > 1 ? 2 : 1
            }
            
            sections = [DetailsSection(type: .hotelImage, count: hotelDetails.hotelImages.count),
                        DetailsSection(type: .hotelDetails, count: 1),
                        DetailsSection(type: .hotelAddrress, count: 1),
                        DetailsSection(type: .facilities, count: hotelDetails.hotelFacilities.count),
                        DetailsSection(type: .seperator, count: 1),
                        DetailsSection(type: .roomFilter, count: 1),
                        DetailsSection(type: .rooms, count: hotelDetails.hotelRooms.count),
                        DetailsSection(type: .rules, count: 1),
                        DetailsSection(type: .terms, count: 1),
                        DetailsSection(type: .rating, count: 1),
                        DetailsSection(type: .review, count: reviewSectionCount)]
            
            imagesCollectionView.reloadData()
            hotelDetailsCollectionView.reloadData()
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
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        if datePicker.tag == 1 {
            checkinField.text = datePicker.date.stringValue(format: "dd-MM-yyyy")
            if (checkinField.text?.date("dd-MM-yyyy"))! >= (checkoutField.text?.date("dd-MM-yyyy"))! {
                checkoutField.text = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440).stringValue(format: "dd-MM-yyy")
            }
        } else if datePicker.tag == 2 {
            checkoutField.text = datePicker.date.stringValue(format: "dd-MM-yyyy")
        }
        pickerContainer.isHidden = true
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 5)]) //roomfilter section
    }
    
    @IBAction func hideImageTapped(_ sender: UIButton) {
        imageContainer.isHidden = true
    }
    
    @IBAction func openInMapTapped(_ sender: UIButton) {
        if let hotelDetails = hotelDetails {
            let latitude: CLLocationDegrees = Double(hotelDetails.latitude)!
            let longitude: CLLocationDegrees = Double(hotelDetails.longitude)!
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = hotelDetails.hotelName
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func editFilterTapped(_ sender: UIButton) {
        
        assignFilterData()
        
        let slideUpViewHeight: CGFloat = 200
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5,
                       delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
            self.filterInnerView.frame = CGRect(x: 0, y: screenSize.height - slideUpViewHeight, width: screenSize.width, height: slideUpViewHeight)
            self.filterContainer.isHidden = false
            
        }, completion: nil)
        
    }
    
    
    @IBAction func filterActions(_ sender: UIButton) {
        switch sender {
            
        case checkInButton:
            datePicker.tag = 1
            datePicker.minimumDate = Date()
            pickerContainer.isHidden = false
            
        case checkOutButton:
            datePicker.tag = 2
            datePicker.minimumDate = checkinField.text?.date("dd-MM-yyyy")?.adding(minutes: 1440)
            pickerContainer.isHidden = false
            
        case roomMinusButton, roomAddButton, adultMinusButton, adultAddButton, childMinusButton, childAddButton:
            addOrMinusPeople(sender)
            
        case filterSearchButton:
            hotelFilters.adult = adultQty
            hotelFilters.child = childQty
            hotelFilters.roomCount = roomQty
            hotelFilters.checkin = checkinField.text?.date("dd-MM-yyyy")
            hotelFilters.checkout = checkoutField.text?.date("dd-MM-yyyy")
            filterContainer.isHidden = true
            getHotelDetails()
            
        case filterOutsideButton, filterClearButton:
            filterContainer.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func seeAllReviewsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toAllReviews", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RoomSelectionViewController {
            if let index = sender as? Int {
                vc.hotelFilters = hotelFilters
                vc.hotelDetails = hotelDetails
                vc.selectedRoomIndex = index
            }
        } else if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? ReadMoreViewController {
                if let type = sender as? ReadMoreTypes {
                    vc.type = type
                    vc.hotelDetails = hotelDetails
                }
            } else if let vc = nav.topViewController as? SeeAllReviewsViewController {
                print("segue")
                vc.reviews = hotelDetails?.hotelReviews
            }
        }
    }
}

//MARK: - APICalls
extension HotelDetailsViewController {
    func getHotelDetails() {
        showIndicator()
        
        let params: [String: Any] = ["HotelId": hotelID,
                                     "CheckInDate": hotelFilters.checkin!.stringValue(format: "yyyy/MM/dd"),
                                     "CheckOutDate": hotelFilters.checkout!.stringValue(format: "yyyy/MM/dd"),
                                     "AdultCount": hotelFilters.adult!,
                                     "ChildCount": hotelFilters.child!,
                                     "RoomCount": hotelFilters.roomCount!,
                                     "HotelRateFrom": hotelFilters.rate!.from,
                                     "HotelRateTo": hotelFilters.rate!.to,
                                     "Country": SessionManager.shared.getCountry(),
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHotelDetails", http: .post, parameters: params) { (result: HotelDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.hotelDetails = result!.data
                        self.assignFilterData()
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

//MARK: ReadMoreDelegate
extension HotelDetailsViewController: ReadMoreDelegate {
    func showReadMore(for type: ReadMoreTypes, content: String?) {
        performSegue(withIdentifier: "toReadMore", sender: type)
    }
}

//MARK: - CollectionView
extension HotelDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == imagesCollectionView {
            return 1
        }
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imagesCollectionView {
            return hotelDetails?.hotelRooms[imageContainer.tag].roomImages?.count ?? 0
        }
        guard let thisSection = sections?[section] else { return 0 }
        
        if thisSection.type == .facilities {
            if hotelDetails!.hotelFacilities.count > facilityCount {
                return facilityCount
            }
        }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! ImagesCollectionViewCell
            
            if let roomImages = hotelDetails?.hotelRooms[imageContainer.tag].roomImages {
                cell.roomImage.sd_setImage(with: URL(string: roomImages[indexPath.row].roomImage ?? ""), placeholderImage: UIImage(named: "hotel-default-img"))
            }
            
            
            return cell
        }
        
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .hotelImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! HotelImageCollectionViewCell
            
            if let images = hotelDetails?.hotelImages {
                cell.hotelImage.sd_setImage(with: URL(string: images[indexPath.row].imageURL ?? ""), placeholderImage: UIImage(named: "hotel-default-img"))
            }
            
            return cell
            
        } else if thisSection.type == .hotelDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailsCell", for: indexPath) as! HotelDetailsCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                //                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.labelAction(_:)))
                //                cell.detailsLabel.addGestureRecognizer(tap)
                //                cell.detailsLabel.isUserInteractionEnabled = true
                //                tap.delegate = self
                cell.detailsLabel.setAttributedHtmlText(hotelDetails.description)
                cell.detailsLabel.numberOfLines = linesToShow
                cell.hotelName.text = hotelDetails.hotelName
                cell.delegate = self
                
                var starRating = ""
                for _ in 0..<hotelDetails.hotelStar {
                    starRating += "⭑"
                }
                
                cell.starRating.text = "\(starRating) \(hotelDetails.hotelType)"
                
                //                if linesToShow != 0 {
                //                    let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 11.0)
                //                    let readmoreFontColor = UIColor(named: "buttonBackgroundColor")!
                //                    DispatchQueue.main.async {
                //                        cell.detailsLabel.addTrailing(with: "... ", moreText: "Read more ", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                //
                //                    }
                //                }
            }
            
            return cell
        } else if thisSection.type == .hotelAddrress {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addressCell", for: indexPath) as! HotelAddrressCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                let hotelLocation = CLLocationCoordinate2D(latitude: Double(hotelDetails.latitude) ?? 0.0, longitude: Double(hotelDetails.longitude) ?? 0.0)
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                let region = MKCoordinateRegion(center: hotelLocation, span: span)
                cell.addressMap.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = hotelLocation
                annotation.title = hotelDetails.hotelName
                cell.addressMap.addAnnotation(annotation)
                
                cell.addressLabel.text = hotelDetails.address
            }
            
            return cell
            
        } else if thisSection.type == .facilities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "facilitiesCell", for: indexPath) as! HotelFacilitiesCollectionViewCell
            
            if let facilities = hotelDetails?.hotelFacilities {
                cell.moreView.isHidden = true
                cell.facilityIcon.sd_setImage(with: URL(string: facilities[indexPath.row].facilityICon))
                cell.facilityIcon.tintColor = .white
                cell.facilityLabel.text = facilities[indexPath.row].facilityName
                cell.facilityLabel.textColor = .white
                
                let allFacilitites = thisSection.count
                if allFacilitites > facilityCount {
                    if indexPath.row == facilityCount - 1 {
                        cell.moreView.isHidden = false
                        cell.facilityIcon.image = UIImage(systemName: "plus")
                        cell.facilityIcon.tintColor = .tintColor
                        cell.facilityLabel.text = "More"
                        cell.facilityLabel.textColor = .tintColor
                    }
                }
            }
            
            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "separator", for: indexPath) as! SeperatorCell
            
            return cell
        } else if thisSection.type == .roomFilter {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomFilterCell", for: indexPath) as! RoomFilterCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                cell.hotelNameLabel.text = hotelDetails.hotelName
                
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
                
                cell.secondLabel.text = dateText + " | " + roomText + " | " + guestText
                
            }
            
            return cell
        } else if thisSection.type == .rooms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomsCell", for: indexPath) as! HotelRoomsCollectionViewCell
            
            cell.imageButton.tag = indexPath.row
            
            if let rooms = hotelDetails?.hotelRooms[indexPath.row] {
                cell.delegate = self
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(rooms.actualPrice, rooms.offerPrice, fontSize: fontSize!)
                cell.offLabel.isHidden = true
                if rooms.roomImages?.count != 0 {
                    cell.roomImage.sd_setImage(with: URL(string: rooms.roomImages?[0].roomImage ?? ""), placeholderImage: UIImage(named: "hotel-default-img"))
                }
                cell.roomName.text = rooms.roomType
                
                var facilities = ""
                for facility in rooms.roomFacilities {
                    facilities += "✔ \(facility.roomFacilityName)\n"
                }
                cell.featuresLabel.text = facilities.trimmingCharacters(in: .whitespacesAndNewlines)
                
                cell.soldOutView.isHidden = true
                cell.selectButton.isEnabled = true
                if rooms.isSoldOut == 1 {
                    cell.selectButton.isEnabled = false
                    cell.soldOutView.isHidden = false
                }
                
            }
            
            
            
            
            return cell
        } else if thisSection.type == .rules {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rulesCell", for: indexPath) as! PropertyRulesCollectionViewCell
            if let hotelDetails = hotelDetails {
                cell.ruleLabel.setAttributedHtmlText(hotelDetails.propertyRules)
                
                cell.delegate = self
            }
            
            return cell
        } else if thisSection.type == .terms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as! TermsCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                
                cell.termsLabel.setAttributedHtmlText(hotelDetails.termsAndCondition)
                //                cell.termsLabel.numberOfLines = termsLinesToShow
                cell.delegate = self
                
                //                if termsLinesToShow != 0 {
                //                    let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 11.0)
                //                    let readmoreFontColor = UIColor(named: "buttonBackgroundColor")!
                //                    DispatchQueue.main.async {
                //                        cell.termsLabel.addTrailing(with: "... ", moreText: "Read more ", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                //
                //                    }
                //                }
            }
            
            
            return cell
        } else if thisSection.type == .rating {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingCell", for: indexPath) as! RatingCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                if hotelDetails.userRatingCount > 0 {
                    cell.ratingLabel.text = "Overall Rating \(hotelDetails.userRating) (\(hotelDetails.userRatingCount))"
                    cell.rating.isHidden = false
                    cell.rating.rating = hotelDetails.userRating
                } else {
                    cell.ratingLabel.text = "No ratings"
                    cell.rating.isHidden = true
                }
            }
            
            return cell
        } else if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCollectionViewCell
            
            if let reviews = hotelDetails?.hotelReviews.filter({ $0.hotelReview != "" }) {
                //                if let image = review.customerImage {
                //                    cell.customerImage.sd_setImage(with: URL(string: image))
                //                }
                let review = reviews[indexPath.row]
                cell.seeAllreviewButton.isHidden = true
                cell.review.text = review.hotelReview
                cell.reviewTitle.text = review.reviewTitle
                cell.ratingLabel.text = review.hotelRating?.stringValue()
                cell.customerName.text = "- Reviewed by \(review.customerName) on \(review.reviewDate.date("dd/MM/yyyy HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")"
                
                if reviews.count > 2 && indexPath.row == 1 {
                    cell.seeAllreviewButton.isHidden = false
                }
            }
            
            return cell
        } else {
            fatalError("Unknown section!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detailsHeader", for: indexPath) as! HotelDetailsHeaderView
            
            guard let thisSection = sections?[indexPath.section] else { return headerView }
            
            if thisSection.type == .hotelAddrress {
                headerView.titleLabel.text = "Address"
            } else if thisSection.type == .facilities {
                headerView.titleLabel.text = "Amenities"
            } else if thisSection.type == .rules {
                headerView.titleLabel.text = "Property Rules"
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "hotelDetailsFooter", for: indexPath) as! HotelDetailsFooterView
            
            footerView.configure(with: hotelDetails?.hotelImages.count ?? 0)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
        default:
            return UICollectionReusableView()
            //            assert(false, "Invalid Element Type")
        }
    }
}

extension HotelDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .rooms {
            if SessionManager.shared.getLoginDetails() == nil {
                tabBarDelegate?.switchTab(0)
                tabBarDelegate?.presentVC("toLogin")
            } else {
                if hotelDetails!.hotelRooms[indexPath.row].isSoldOut != 1 {
                    hotelFilters.roomDetails = Room(hotelID: hotelID, roomID: hotelDetails!.hotelRooms[indexPath.row].roomID)
                    performSegue(withIdentifier: "toRoomSelect", sender: indexPath.row)
                }
            }
        } else if thisSection.type == .facilities {
            let allFacilties = thisSection.count
            if allFacilties > facilityCount {
                facilityCount = allFacilties
                collectionView.reloadItems(at: [IndexPath(row: 0, section: 3)])
            }
        }
        
    }
}

extension HotelDetailsViewController: UIGestureRecognizerDelegate {
    @objc func labelAction(_ gesture: UITapGestureRecognizer) {
        if linesToShow == 0 {
            linesToShow = 3
        } else {
            linesToShow = 0
        }
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
    }
    
    @objc func termsLabelAction(_ gesture: UITapGestureRecognizer) {
        if termsLinesToShow == 0 {
            termsLinesToShow = 3
        } else {
            termsLinesToShow = 0
        }
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 8)])
    }
}

extension HotelDetailsViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        hotelDetailsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HotelDetailsViewController: ViewImageDelegate {
    func imageTapped(_ tag: Int) {
        imageContainer.tag = tag
        imageContainer.isHidden = false
        imagesCollectionView.reloadData()
        imagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
}

//Layout
extension HotelDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .hotelImage {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.6))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [sectionFooter]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: -30, trailing: 20)
                
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }
                    
                    let page = round(offset.x / self.view.bounds.width)
                    
                    self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }
                
            } else if thisSection.type == .hotelDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .hotelAddrress {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(containerWidth > 500 ? 0.3 : 0.6))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .facilities {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                      heightDimension: .estimated(60))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
            } else if thisSection.type == .roomFilter {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .rooms {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerWidth > 500 ? 0.425 : 0.85),
                                                       heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .rules {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(20))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(20))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(25))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .terms {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .rating {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 8)
                
            } else if thisSection.type == .review {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                //                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 20, trailing: 8)
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func createImageLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            
            let section: NSCollectionLayoutSection
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
