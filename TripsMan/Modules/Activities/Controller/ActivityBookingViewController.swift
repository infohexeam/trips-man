//
//  ActivityBookingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/04/23.
//

import UIKit

fileprivate var activityFieldTexts = [IndexPath:GuestFds]()
fileprivate var createdActivityBookingID: Int?

class ActivityBookingViewController: UIViewController {
    
    @IBOutlet weak var activityCollectionView: UICollectionView! {
        didSet {
            activityCollectionView.collectionViewLayout = createLayout()
            activityCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            activityCollectionView.dataSource = self
//            activityCollectionView.delegate = self
        }
    }
    
    var listType: ListType?
    
    var activityManager: ActivityBookingManager?
    var meetupManager: MeetupBookingManager?
    var parser = Parser()
    
    var activityBookedData: ActivityBooking?
    var meetupBookingData: MeetupBooking?
    
    var fontSize: CGFloat? = nil
    
    var activityFilters = ActivityFilters()
    var meetupFilters = MeetupFilters()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var title = ""
        if listType == .activities {
            title = "Activity Booking"
        } else if listType == .meetups {
            title = "Meetup Booking"
        }
        addBackButton(with: title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                                               
        if let activityDetails = activityFilters.activityDetails {
            activityManager = ActivityBookingManager(activityDetails: activityDetails)
        } else if let meetupDetails = meetupFilters.meetupDetails {
            meetupManager = MeetupBookingManager(meetupDetails: meetupDetails)
        }
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if isGuestDetailsValid() {
            if listType == .activities {
                createActivityBooking()
            } else {
                createMeetupBooking()
            }
        } else {
            print("\n\nerrrrror")
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isGuestDetailsValid() -> Bool {
        var isValid = false
        var sect = 0
        
        if listType == .activities {
            sect = activityManager?.getSection(.customerDetails) ?? 0
        } else if listType == .meetups {
            sect = meetupManager?.getSection(.customerDetails) ?? 0
        }
        let primary = activityFieldTexts.filter { $0.key == [sect, 0] }
        
        if primary.count == 0 {
            self.view.makeToast(Validation.primaryCustomerDetails)
        } else {
            let index = IndexPath(row: 0, section: sect)
            if primary[index]?.name != "" && primary[index]?.countryCode != "" && primary[index]?.contactNumber != "" && primary[index]?.emailID != "" && primary[index]?.gender != "" && primary[index]?.age != "" {
                isValid = true
            } else {
                self.view.makeToast(Validation.primaryCustomerDetails)
            }
        }
        return isValid
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActivitySummaryViewController {
            vc.activityBookingData = activityBookedData
            vc.meetupBookingData = meetupBookingData
            vc.listType = listType
        }
    }
}

//MARK: - APICalls
extension ActivityBookingViewController {
    func createActivityBooking() {
        showIndicator()
        
        var guests = [[String: Any]]()
        print(activityFieldTexts)
        let sect = activityManager?.getSection(.customerDetails) ?? 0
        let primary = activityFieldTexts.filter { $0.key == [sect, 0] }
        
        
        for each in activityFieldTexts {
            guests.append(["id": 0,
                           "contactNo": each.value.countryCode + each.value.contactNumber,
                           "guestName": each.value.name,
                           "emailId": each.value.emailID,
                           "gender": each.value.gender,
                           "isPrimary": each.value == primary.first?.value ? 1 : 0,
                           "age": each.value.age.intValue()])
        }
        
        var params: [String: Any] = ["bookingType": "create",
                                     "bookingDate": Date().stringValue(format: "yyyy-MM-dd"),
                                     "activityId": activityFilters.activityDetails?.activityID ?? 0,
                                     "bookingFrom": activityFilters.activityDate!.stringValue(format: "yyyy-MM-dd"),
                                     "userId": SessionManager.shared.getLoginDetails()!.userid!,
                                     "country": SessionManager.shared.getCountry(),
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage(),
                                     "adultCount": activityFilters.memberCount,
                                     "booking_Guest": guests]
        
        if createdActivityBookingID != nil {
            params["bookingType"] = "update"
            params["bookingId"] = createdActivityBookingID
        }
        
        print("\n\n params: \(params)")
        
        parser.sendRequestLoggedIn(url: "api/CustomerActivity/CreateCustomerActivityBooking", http: .post, parameters: params) { (result: ActivityBookingData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityBookedData = result!.data
                        createdActivityBookingID = result!.data.bookingId
                        self.performSegue(withIdentifier: "toActivitySummary", sender: nil)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    func createMeetupBooking() {
        showIndicator()
        
        var guests = [[String: Any]]()
        print(activityFieldTexts)
        let sect = meetupManager?.getSection(.customerDetails) ?? 0
        let primary = activityFieldTexts.filter { $0.key == [sect,0] }
        
        
        for each in activityFieldTexts {
            guests.append(["id": 0,
                           "contactNo": each.value.countryCode + each.value.contactNumber,
                           "guestName": each.value.name,
                           "emailId": each.value.emailID,
                           "gender": each.value.gender,
                           "isPrimary": each.value == primary.first?.value ? 1 : 0,
                           "age": each.value.age.intValue()])
        }
        
        var params: [String: Any] = ["bookingType": "create",
                                     "bookingDate": Date().stringValue(format: "yyyy-MM-dd"),
                                     "meetupId": meetupFilters.meetupDetails?.meetupID ?? 0,
                                     "userId": SessionManager.shared.getLoginDetails()!.userid!,
                                     "country": SessionManager.shared.getCountry(),
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage(),
                                     "booking_Guest": guests]
        
        if createdActivityBookingID != nil {
            params["bookingType"] = "update"
            params["bookingId"] = createdActivityBookingID
        }
        
        print("\n\n params: \(params)")
        
        parser.sendRequestLoggedIn(url: "api/CustomerWebMeetup/Web/CreateCustomerMeetupBooking", http: .post, parameters: params) { (result: MeetupBookingData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.meetupBookingData = result!.data
                        createdActivityBookingID = result!.data.bookingId
                        self.performSegue(withIdentifier: "toActivitySummary", sender: nil)
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


//MARK: - CollectionView
extension ActivityBookingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if listType == .activities {
            return activityManager?.getSections()?.count ?? 0
        }
        return meetupManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if listType == .activities {
            guard let thisSection = activityManager?.getSections()?[section] else { return 0 }
            return thisSection.count
        }
        guard let thisSection = meetupManager?.getSections()?[section] else { return 0 }
        return thisSection.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let activitySection = activityManager?.getSections()?[indexPath.section]
        let meetupSection = meetupManager?.getSections()?[indexPath.section]
        
        
        if activitySection?.type == .summary || meetupSection?.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activitySummaryCell", for: indexPath) as! ActivitySummaryCollectionViewCell
            
            if let activityDetails = activityManager?.getActivityDetails() {
                var imageURL = ""
                let featuredImage = activityDetails.activityImages.filter { $0.isFeatured == 1}
                if featuredImage.count != 0 {
                    imageURL = featuredImage[0].imageURL
                } else {
                    imageURL = activityDetails.activityImages.count > 0 ? activityDetails.activityImages[0].imageURL : ""
                }
                cell.activityImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(systemName: K.activityPlaceholderImage))
                cell.activityName.text = activityDetails.activityName
                cell.locationLabel.text = activityDetails.activityLocation
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(activityDetails.costPerPerson, activityDetails.offerPrice, fontSize: fontSize!)
                cell.taxlabel.text = "+ \(SessionManager.shared.getCurrency()) \(activityDetails.serviceChargeValue) taxes and fee per person"
                
                cell.dateLabel.text = activityFilters.activityDate!.stringValue(format: "EEEE\ndd-MM-yyyy")
            }
            
            if let meetupDetails = meetupManager?.getMeetupDetails() {
                let featuredImage = meetupDetails.meetupImages.filter { $0.isFeatured == 1}
                if featuredImage.count != 0 {
                    cell.activityImage.sd_setImage(with: URL(string: featuredImage[0].imageURL), placeholderImage: UIImage(systemName: K.meetupPlaceholderImage))
                }
                cell.activityName.text = meetupDetails.meetupName
                cell.locationLabel.text = meetupDetails.address
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(meetupDetails.costPerPerson, meetupDetails.offerAmount, fontSize: fontSize!)
                cell.taxlabel.text = "+ \(SessionManager.shared.getCurrency()) \(meetupDetails.serviceCharge) taxes and fee per person"
                
                cell.dateLabel.text = meetupDetails.meetupDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "EEEE\ndd-MM-yyyy")
            }
            
            
            return cell
        } else if activitySection?.type == .header || meetupSection?.type == .header {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityHeaderCell", for: indexPath) as! ActivityHeaderCell
            
            
            return cell
        } else if activitySection?.type == .customerDetails || meetupSection?.type == .customerDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCustomerCell", for: indexPath) as! ActivityCustomerCollectionViewCell
            
            cell.setupView()
            cell.delegate = self
            cell.cvcDelegate = self
            cell.genderButton.tag = indexPath.section
            cell.customerField.text = activityFieldTexts[indexPath]?.name
            cell.countryCodeField.text = activityFieldTexts[indexPath]?.countryCode
            cell.contactField.text = activityFieldTexts[indexPath]?.contactNumber
            cell.emailField.text = activityFieldTexts[indexPath]?.emailID
            cell.genderField.text = activityFieldTexts[indexPath]?.gender
            cell.ageField.text = activityFieldTexts[indexPath]?.age
            
            
            return cell
        } else if activitySection?.type == .action || meetupSection?.type == .action {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityActionCell", for: indexPath) as! ActivityActionCollectionViewCell
            
            
            
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}


//MARK: - CollectionViewCellDelegate
extension ActivityBookingViewController: CollectionViewCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: UICollectionViewCell) {
        if let indexPath = activityCollectionView.indexPath(for: cell), let text = textField.text {
            if textField.tag == 1 {
                activityFieldTexts[indexPath] = GuestFds(name: text, countryCode: activityFieldTexts[indexPath]?.countryCode ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 2 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", countryCode: activityFieldTexts[indexPath]?.countryCode ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: text, age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 3 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", countryCode: activityFieldTexts[indexPath]?.countryCode ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: text)
            } else if textField.tag == 4 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", countryCode: activityFieldTexts[indexPath]?.countryCode ?? "", contactNumber: text, emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 5 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", countryCode: activityFieldTexts[indexPath]?.countryCode ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: text, gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 6 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", countryCode: text, contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            }
            print("\n text changed: \(activityFieldTexts[indexPath])")
        }
    }

    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: UICollectionViewCell) -> Bool {
        return true
    }

    func collectionViewCell(deleteTappedFrom cell: UICollectionViewCell) {

    }


}


//MARK: - DynamicCellDelegate
extension ActivityBookingViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        activityCollectionView.collectionViewLayout.invalidateLayout()
    }
}



//MARK: - Layout
extension ActivityBookingViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let activitySection = self.activityManager?.getSections()?[sectionIndex]
            let meetupSection = self.meetupManager?.getSections()?[sectionIndex]
            
            
            
            let section: NSCollectionLayoutSection
            
            if activitySection?.type == .summary || meetupSection?.type == .summary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if activitySection?.type == .header || meetupSection?.type == .header {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if activitySection?.type == .customerDetails || meetupSection?.type == .customerDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if activitySection?.type == .action || meetupSection?.type == .action {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


