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
    var facilityCount = 5
    
    var hotelID = 0
    
    var hotelFilters = HotelListingFilters()
    
    let parser = Parser()
    var hotelDetails: HotelDetails? {
        didSet {
            loadSection()
        }
    }
    
    let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
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
        
        addBackButton(with: "Hotel Details".localized())
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
    
    func getSection(_ type: SectionTypes) -> Int? {
        if sections != nil {
            for i in 0..<sections!.count {
                if sections![i].type == type {
                    return i
                }
            }
        }
        return nil
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
            if let latitude = Double(hotelDetails.latitude), let longitude = Double(hotelDetails.longitude) {
                openInMap(latitude: latitude, longitude: longitude, name: hotelDetails.hotelName)
            }
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
                if let tag = sender as? Int {
                    if let hotelDetails = hotelDetails {
                        if tag == 100 { //HotelDetails
                            vc.readMore = ReadMore(title: hotelDetails.hotelName, content: hotelDetails.description)
                        } else if tag == 101 { //Property Rule
                            vc.readMore = ReadMore(title: "Property Rules".localized(), content: hotelDetails.propertyRules)
                        } else if tag == 102 {
                            vc.readMore = ReadMore(title: "Terms and Conditions".localized(), content: hotelDetails.termsAndCondition)
                        }
                    }
                    
                    
                }
            } else if let vc = nav.topViewController as? SeeAllReviewsViewController {
                vc.reviews = hotelDetails?.hotelReviews
            }
        } else if let vc = segue.destination as? RoomDetailsViewController {
            if let index = sender as? Int {
                vc.hotelRoom = hotelDetails?.hotelRooms[index]
                vc.index = index
                vc.delegate = self
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
                                     "Country": SessionManager.shared.getCountry().countryCode,
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage().code]
        
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
                    self.view.makeToast(K.apiErrorMessage)
                }
            }
        }
    }
}

//MARK: ReadMoreDelegate
extension HotelDetailsViewController: ReadMoreDelegate {
    func showReadMore(_ tag: Int) {
        performSegue(withIdentifier: "toReadMore", sender: tag)
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
            if hotelDetails?.hotelRooms.count ?? 0 > 0 {
                return hotelDetails?.hotelRooms[imageContainer.tag].roomImages?.count ?? 0
            }
            return 0
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
                cell.roomImage.sd_setImage(with: URL(string: roomImages[indexPath.row].roomImage ?? ""), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
            }
            
            
            return cell
        }
        
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .hotelImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! HotelImageCollectionViewCell
            
            if let images = hotelDetails?.hotelImages {
                cell.hotelImage.sd_setImage(with: URL(string: images[indexPath.row].imageURL ?? ""), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
            }
            
            return cell
            
        } else if thisSection.type == .hotelDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailsCell", for: indexPath) as! HotelDetailsCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                cell.readMoreView.isHidden = true
                cell.detailsLabel.setAttributedHtmlText(hotelDetails.description)
                cell.detailsLabel.numberOfLines = 0
                if cell.detailsLabel.lines() > K.readMoreContentLines {
                    cell.readMoreView.isHidden = false
                }
                cell.detailsLabel.numberOfLines = K.readMoreContentLines
                cell.hotelName.text = hotelDetails.hotelName
                cell.delegate = self
                
                var starRating = ""
                for _ in 0..<hotelDetails.hotelStar {
                    starRating += "⭑"
                }
                cell.starRating.text = "\(starRating) \(hotelDetails.hotelType)"
                
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
                
                cell.addressLabel.text = hotelDetails.address.capitalizedSentence
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
                        cell.facilityLabel.text = "More".localized()
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
                
                let roomText = hotelFilters.roomCount!.oneOrMany("Room")
                let guests = hotelFilters.adult! + hotelFilters.child!
                let guestText = guests.oneOrMany("Guest")
                
                cell.secondLabel.text = dateText + " | " + roomText + " | " + guestText
                
            }
            
            return cell
        } else if thisSection.type == .rooms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomsCell", for: indexPath) as! HotelRoomsCollectionViewCell
            
            cell.imageButton.tag = indexPath.row
            cell.selectButton.tag = indexPath.row
            cell.viewMoreButton.tag = indexPath.row
            cell.fullScreenButton.isHidden = true
            cell.delegate = self

            
            if let rooms = hotelDetails?.hotelRooms[indexPath.row] {
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(rooms.actualPrice, rooms.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(SessionManager.shared.getCurrency()) \(rooms.serviceChargeValue)\n" + "taxes & fee per night".localized()
                cell.offLabel.isHidden = true
                if rooms.offerPrice > 0 {
                    cell.offLabel.text = " " + "\(rooms.offerPrice.percentage(rooms.actualPrice)) % " + "off".localized() + " "
                    cell.offLabel.isHidden = false
                }
                
                cell.multipleButton.isHidden = true
                if rooms.roomImages?.count != 0 {
                    let roomImage: String = rooms.roomImages?.filter( {$0.isFeatured == 1 }).last?.roomImage ?? (rooms.roomImages?[0].roomImage ?? "")
                    cell.roomImage.sd_setImage(with: URL(string: roomImage), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
                    if rooms.roomImages!.count > 1 {
                        cell.multipleButton.isHidden = false
                    }
                    cell.fullScreenButton.isHidden = false
                    cell.hasRoomImage = true
                }
                cell.roomName.text = rooms.roomType
                
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
                cell.readMoreView.isHidden = true
                cell.ruleLabel.setAttributedHtmlText(hotelDetails.propertyRules)
                cell.ruleLabel.numberOfLines = 0
                if cell.ruleLabel.lines() > K.readMoreContentLines {
                    cell.readMoreView.isHidden = false
                }
                cell.ruleLabel.numberOfLines = K.readMoreContentLines
                
                cell.delegate = self
            }
            
            return cell
        } else if thisSection.type == .terms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as! TermsCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                cell.readMoreView.isHidden = true
                cell.termsLabel.setAttributedHtmlText(hotelDetails.termsAndCondition)
                cell.termsLabel.numberOfLines = 0
                if cell.termsLabel.lines() > K.readMoreContentLines {
                    cell.readMoreView.isHidden = false
                }
                cell.termsLabel.numberOfLines = K.readMoreContentLines
                cell.delegate = self
            }
            
            
            return cell
        } else if thisSection.type == .rating {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingCell", for: indexPath) as! RatingCollectionViewCell
            
            if let hotelDetails = hotelDetails {
                if hotelDetails.userRatingCount > 0 {
                    cell.ratingLabel.text = "Overall Rating".localized() + " \(hotelDetails.userRating) (\(hotelDetails.userRatingCount))"
                    cell.rating.isHidden = false
                    cell.rating.rating = hotelDetails.userRating
                } else {
                    cell.ratingLabel.text = "No ratings".localized()
                    cell.rating.isHidden = true
                }
            }
            
            return cell
        } else if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCollectionViewCell
            
            if let reviews = hotelDetails?.hotelReviews.filter({ $0.hotelReview != "" }) {
                let review = reviews[indexPath.row]
                cell.seeAllreviewButton.isHidden = true
                cell.review.text = review.hotelReview
                cell.reviewTitle.text = review.reviewTitle
                cell.ratingLabel.text = review.hotelRating?.stringValue()
                cell.customerName.text = L.reviewedByText(by: review.customerName, on: review.reviewDate.date("MM/dd/yyyy HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")
                
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
                headerView.titleLabel.text = "Address".localized()
            } else if thisSection.type == .facilities {
                headerView.titleLabel.text = "Amenities".localized()
            } else if thisSection.type == .rules {
                headerView.titleLabel.text = "Property Rules".localized()
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
        
        if thisSection.type == .facilities {
            let allFacilties = thisSection.count
            if allFacilties > facilityCount {
                facilityCount = allFacilties
                collectionView.reloadSections(IndexSet(integer: getSection(.facilities)!))
            }
        }
        
    }
}

extension HotelDetailsViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        hotelDetailsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HotelDetailsViewController: RoomCellDelegate {
    func viewMoreTapped(_ index: Int) {
        performSegue(withIdentifier: "toRoomDetails", sender: index)
    }
    
    func selectTapped(_ index: Int) {
        if SessionManager.shared.getLoginDetails() == nil {
            tabBarDelegate?.switchTab(0)
            tabBarDelegate?.presentVC("toLogin")
        } else {
            if hotelDetails!.hotelRooms[index].isSoldOut != 1 {
                hotelFilters.roomDetails = Room(hotelID: hotelID, roomID: hotelDetails!.hotelRooms[index].roomID)
                performSegue(withIdentifier: "toRoomSelect", sender: index)
            }
        }
    }
    
    func imageTapped(_ tag: Int) {
        imageContainer.tag = tag
        imageContainer.isHidden = false
        imagesCollectionView.reloadData()
        imagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
}

