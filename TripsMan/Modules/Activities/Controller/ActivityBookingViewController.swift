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
    
    var activityManager: ActivityBookingManager?
    var parser = Parser()
    
    var bookedData: ActivityBooking?
    
    var fontSize: CGFloat? = nil
    
    var activityFilters = ActivityFilters()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let activityDetails = activityFilters.activityDetails {
            activityManager = ActivityBookingManager(activityDetails: activityDetails)
        }
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if isGuestDetailsValid() {
            createBooking()
        } else {
            print("\n\nerrrrror")
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isGuestDetailsValid() -> Bool {
        var isValid = false
        let primary = activityFieldTexts.filter { $0.key == [2,0] }
        if primary.count != 0 {
            isValid = true
        }
        return isValid
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActivitySummaryViewController {
            vc.activityBookingData = bookedData
        }
    }
}

//MARK: - APICalls
extension ActivityBookingViewController {
    func createBooking() {
        showIndicator()
        
        var guests = [[String: Any]]()
        print(activityFieldTexts)
        let primary = activityFieldTexts.filter { $0.key == [2,0] }
        
        
        for each in activityFieldTexts {
            guests.append(["id": 0,
                           "contactNo": each.value.contactNumber,
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
                        self.bookedData = result!.data
                        createdActivityBookingID = result!.data.bookingID
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
        return activityManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = activityManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activitySummaryCell", for: indexPath) as! ActivitySummaryCollectionViewCell
            
            if let activityDetails = activityManager?.getActivityDetails() {
                let featuredImage = activityDetails.activityImages.filter { $0.isFeatured == 1}
                if featuredImage.count != 0 {
                    cell.activityImage.sd_setImage(with: URL(string: featuredImage[0].imageURL), placeholderImage: UIImage(systemName: K.activityPlaceholderImage))
                }
                cell.activityName.text = activityDetails.activityName
                cell.locationLabel.text = activityDetails.activityLocation
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                cell.priceLabel.addPriceString(activityDetails.costPerPerson, activityDetails.offerPrice, fontSize: fontSize!)
                cell.taxlabel.text = "+ \(SessionManager.shared.getCurrency()) \(activityDetails.serviceChargeValue) taxes and fee per person"
                
                cell.dateLabel.text = activityFilters.activityDate!.stringValue(format: "EEEE\ndd-MM-yyyy")
            }
            
            
            return cell
        } else if thisSection.type == .header {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityHeaderCell", for: indexPath) as! ActivityHeaderCell
            
            
            return cell
        } else if thisSection.type == .customerDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCustomerCell", for: indexPath) as! ActivityCustomerCollectionViewCell
            
            cell.setupView()
            cell.delegate = self
            cell.cvcDelegate = self
            cell.genderButton.tag = indexPath.section
            cell.customerField.text = activityFieldTexts[indexPath]?.name
            cell.contactField.text = activityFieldTexts[indexPath]?.contactNumber
            cell.emailField.text = activityFieldTexts[indexPath]?.emailID
            cell.genderField.text = activityFieldTexts[indexPath]?.gender
            cell.ageField.text = activityFieldTexts[indexPath]?.age
            
            
            return cell
        } else if thisSection.type == .action {
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
                activityFieldTexts[indexPath] = GuestFds(name: text, contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 2 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: text, age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 3 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: text)
            } else if textField.tag == 4 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", contactNumber: text, emailID: activityFieldTexts[indexPath]?.emailID ?? "", gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 5 {
                activityFieldTexts[indexPath] = GuestFds(name: activityFieldTexts[indexPath]?.name ?? "", contactNumber: activityFieldTexts[indexPath]?.contactNumber ?? "", emailID: text, gender: activityFieldTexts[indexPath]?.gender ?? "", age: activityFieldTexts[indexPath]?.age ?? "")
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
                        
            guard let thisSection = self.activityManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .summary {
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
                
            } else if thisSection.type == .header {
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
                
            } else if thisSection.type == .customerDetails {
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
                
            } else if thisSection.type == .action {
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


