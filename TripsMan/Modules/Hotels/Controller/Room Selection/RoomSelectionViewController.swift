//
//  RoomSelectionViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/09/22.
//

import UIKit

fileprivate var textFieldsTexts = [IndexPath:GuestFds]()
fileprivate var createdBookingID: Int?

struct GuestFds: Codable, Equatable {
    var name: String = ""
    var countryCode: String
    var contactNumber: String = ""
    var emailID: String = ""
    var gender: String = ""
    var age: String = ""
}

class RoomSelectionViewController: UIViewController {
        
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
        }
    }
    
    
    
    enum SectionTypes {
        case summary
        case primaryFields
        case guestFields
        case actions
    }
    
    struct RoomSelectionSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [RoomSelectionSection]? = nil
    
    var fontSize: CGFloat? = nil
    
    var hotelFilters = HotelListingFilters()
    var hotelDetails: HotelDetails?
    var selectedRoomIndex = 0
    
    let parser = Parser()
    var bookedData: CreateBooking?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Room Selection".localized())
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardOnTap()
        
        textFieldsTexts = [IndexPath:GuestFds]()
        createdBookingID = nil
        sections = [RoomSelectionSection(type: .summary, count: 1),
                    RoomSelectionSection(type: .primaryFields, count: 1),
                    RoomSelectionSection(type: .actions, count: 1)]
        
        collectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
    }
    
    func isGuestDetailsValid() -> Bool {
        
        
        var isValid = false

        let sect = getSection(.primaryFields)
        let primary = textFieldsTexts.filter { $0.key == [sect!,0] }
        if primary.count == 0 {
            self.view.makeToast(Validation.htlPrimaryGuestDetails)
        } else {
            let index = IndexPath(row: 0, section: sect!)
            if primary[index]?.name != "" && primary[index]?.contactNumber != "" && primary[index]?.countryCode != "" && primary[index]?.emailID != "" && primary[index]?.gender != "" && primary[index]?.age != "" {
                isValid = true
            } else {
                self.view.makeToast(Validation.htlPrimaryGuestDetails)
            }
        }
        
        return isValid
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RoomSelectionSummaryViewController {
            vc.bookedData = bookedData
        }
    }
    
    
    
}

extension RoomSelectionViewController {
    
    @IBAction func addGuestTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let guests = sections?.filter { $0.type == .guestFields }
        let totalGuests = (hotelFilters.adult ?? 0) + (hotelFilters.child ?? 0)
        if (guests?.count ?? 0) >= totalGuests - 1 {
            self.view.makeToast(L.addGuestValidationMessage(guestCount: totalGuests))
        } else {
            let sectionCount = sections?.count ?? 1
            sections?.insert(RoomSelectionSection(type: .guestFields, count: 1), at: sectionCount - 1)
            collectionView.reloadData()
        }
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        print(textFieldsTexts)
        if isGuestDetailsValid() {
            createBooking()
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - APICalls
extension RoomSelectionViewController {
    
    func createBooking() {
        showIndicator()
        
        let room: [[String: Any]] = [["id": 0,
                                      "room_id": hotelFilters.roomDetails!.roomID,
                                      "room_count": hotelFilters.roomCount!]]
        var guests = [[String: Any]]()
        let primary = textFieldsTexts.filter { $0.key == [1,0] }
        
        
        
        for each in textFieldsTexts {
            //gender is passed as string to api, and it should be in english
            let gender = K.genders.filter { $0.localized() == each.value.gender }.last ?? ""
            guests.append(["id": 0,
                           "contactNo": each.value.countryCode + each.value.contactNumber,
                           "guestName": each.value.name,
                           "emailId": each.value.emailID,
                           "gender": gender,
                           "isPrimary": each.value == primary.first!.value ? 1 : 0,
                           "age": each.value.age.intValue(),
                           "status": 1])
        }
        
        var params: [String: Any] = ["bookingType": "create",
                                     "bookingDate": Date().stringValue(format: "yyyy-MM-dd"),
                                     "hotelId": hotelFilters.roomDetails!.hotelID,
                                     "bookingFrom": hotelFilters.checkin!.stringValue(format: "yyyy-MM-dd"),
                                     "bookingTo": hotelFilters.checkout!.stringValue(format: "yyyy-MM-dd"),
                                     "status": 0,
                                     "userId": SessionManager.shared.getLoginDetails()!.userid!,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code,
                                     "booking_Guest": guests,
                                     "booked_room": room,
                                     "adultCount": hotelFilters.adult!,
                                     "childCount": hotelFilters.child!]
        
        if createdBookingID != nil {
            params["bookingType"] = "update"
            params["bookingId"] = createdBookingID
        }
        
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/CreateCustomerHotelBooking", http: .post, parameters: params) { (result: CreateBookingData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.bookedData = result!.data
                        createdBookingID = result!.data.bookingID
                        self.performSegue(withIdentifier: "toRoomSelectionSummary", sender: nil)
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


//MARK: - CollectionView
extension RoomSelectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomSummaryCell", for: indexPath) as! RoomSummaryCollectionViewCell
            
            if fontSize == nil {
                fontSize = cell.priceLabel.font.pointSize
            }
            if let hotelDetails = hotelDetails {
                if hotelDetails.userRatingCount > 0 {
                    cell.ratingText.text = "\(hotelDetails.userRating)/5"
                    cell.ratingView.isHidden = false
                } else {
                    cell.ratingView.isHidden = true
                }
                cell.hotelName.text = hotelDetails.hotelName
                cell.hotelImage.sd_setImage(with: URL(string: hotelDetails.featuredImage ?? ""), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
                cell.addressLabel.text = hotelDetails.address.capitalizedSentence
                
                let room = hotelDetails.hotelRooms[selectedRoomIndex]
                cell.roomName.text = room.roomType
                if (room.roomImages?.count != 0) {
                    if let roomImage = room.roomImages?[0].roomImage {
                        cell.roomImage.sd_setImage(with: URL(string: roomImage), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
                    }
                }
                
                cell.priceLabel.addPriceString(room.actualPrice, room.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(room.serviceChargeValue.attachCurrency)\n" + "taxes & fee per night".localized()
            }
            return cell
            
        } else if thisSection.type == .primaryFields {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryFieldCell", for: indexPath) as! PrimaryFieldCollectionViewCell
            cell.delegate = self
            cell.cvcDelegate = self
            cell.setupView()
            cell.checkinField.text = hotelFilters.checkin?.stringValue(format: "dd-MM-yyyy")
            cell.checkoutField.text = hotelFilters.checkout?.stringValue(format: "dd-MM-yyyy")
            cell.genderButton.tag = indexPath.section
            cell.primayGuestField.text = textFieldsTexts[indexPath]?.name
            cell.countryCodeField.text = textFieldsTexts[indexPath]?.countryCode
            cell.contactField.text = textFieldsTexts[indexPath]?.contactNumber
            cell.emailField.text = textFieldsTexts[indexPath]?.emailID
            cell.genderField.text = textFieldsTexts[indexPath]?.gender
            cell.ageField.text = textFieldsTexts[indexPath]?.age
            
            return cell
        } else if thisSection.type == .guestFields {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guestFieldCell", for: indexPath) as! GuestFieldCollectionViewCell
            
            cell.delegate = self
            cell.cvcDelegate = self
            cell.setupView()
            cell.genderButton.tag = indexPath.section
            cell.deleteButton.tag = indexPath.section
            cell.guestNameField.text = textFieldsTexts[indexPath]?.name
            cell.genderField.text = textFieldsTexts[indexPath]?.gender
            cell.ageField.text = textFieldsTexts[indexPath]?.age

            
            return cell
        } else if thisSection.type == .actions {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionsCell", for: indexPath) as! RoomSelectionActionsCollectionViewCell
            
            return cell
        } else {
            fatalError("Unknown section!")
        }
        
    }
}


extension RoomSelectionViewController: CollectionViewCellDelegate {
    func collectionViewCell(deleteTappedFrom cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            sections?.remove(at: indexPath.section)
            textFieldsTexts.removeValue(forKey: indexPath)
            UIView.performWithoutAnimation {
                collectionView.reloadData()
            }
        }
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: UICollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell), let text = textField.text {
            if textField.tag == 1 {
                textFieldsTexts[indexPath] = GuestFds(name: text, countryCode: textFieldsTexts[indexPath]?.countryCode ?? "", contactNumber: textFieldsTexts[indexPath]?.contactNumber ?? "", emailID: textFieldsTexts[indexPath]?.emailID ?? "", gender: textFieldsTexts[indexPath]?.gender ?? "", age: textFieldsTexts[indexPath]?.age ?? "")
            } else if textField.tag == 2 {
                textFieldsTexts[indexPath] = GuestFds(name: textFieldsTexts[indexPath]?.name ?? "", countryCode: textFieldsTexts[indexPath]?.countryCode ?? "", contactNumber: text, emailID: textFieldsTexts[indexPath]?.emailID ?? "", gender: textFieldsTexts[indexPath]?.gender ?? "", age: textFieldsTexts[indexPath]?.age ?? "")
                
            } else if textField.tag == 3 {
                textFieldsTexts[indexPath] = GuestFds(name: textFieldsTexts[indexPath]?.name ?? "", countryCode: textFieldsTexts[indexPath]?.countryCode ?? "", contactNumber: textFieldsTexts[indexPath]?.contactNumber ?? "", emailID: text, gender: textFieldsTexts[indexPath]?.gender ?? "", age: textFieldsTexts[indexPath]?.age ?? "")
            } else if textField.tag == 4 {
                textFieldsTexts[indexPath] = GuestFds(name: textFieldsTexts[indexPath]?.name ?? "", countryCode: textFieldsTexts[indexPath]?.countryCode ?? "", contactNumber: textFieldsTexts[indexPath]?.contactNumber ?? "", emailID: textFieldsTexts[indexPath]?.emailID ?? "", gender: textFieldsTexts[indexPath]?.gender ?? "", age: text)
            } else if textField.tag == 5 {
                textFieldsTexts[indexPath] = GuestFds(name: textFieldsTexts[indexPath]?.name ?? "", countryCode: textFieldsTexts[indexPath]?.countryCode ?? "", contactNumber: textFieldsTexts[indexPath]?.contactNumber ?? "", emailID: textFieldsTexts[indexPath]?.emailID ?? "", gender: text, age: textFieldsTexts[indexPath]?.age ?? "")
            } else if textField.tag == 6 {
                textFieldsTexts[indexPath] = GuestFds(name: textFieldsTexts[indexPath]?.name ?? "", countryCode: text, contactNumber: textFieldsTexts[indexPath]?.contactNumber ?? "", emailID: textFieldsTexts[indexPath]?.emailID ?? "", gender: textFieldsTexts[indexPath]?.gender ?? "", age: textFieldsTexts[indexPath]?.age ?? "")
            }
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: UICollectionViewCell) -> Bool {
        return true
    }
    
    
}

extension RoomSelectionViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
}

//MARK: - Layout
extension RoomSelectionViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .summary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                
            } else if thisSection.type == .primaryFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .guestFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .actions {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
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
    
    func updateLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .primaryFields {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


protocol DynamicCellHeightDelegate {
    func updateHeight()
}
