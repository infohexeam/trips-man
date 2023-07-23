//
//  PackageBookingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 24/03/23.
//

import UIKit

fileprivate var packageFieldTexts = [IndexPath:GuestFds]()
fileprivate var createdPackageBookingID: Int?

class PackageBookingViewController: UIViewController {
    
    @IBOutlet weak var packageCollectionView: UICollectionView! {
        didSet {
            packageCollectionView.collectionViewLayout = createLayout()
            packageCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            packageCollectionView.dataSource = self
//            packageCollectionView.delegate = self
        }
    }
    
    var packageManager: PackageBookingManager?
    var parser = Parser()
    var packageFilter = PackageFilters()
    
    var bookedData: PackageBooking?
    
    var fontSize: CGFloat? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Package Booking".localized())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createdPackageBookingID = nil
        packageFieldTexts = [IndexPath:GuestFds]()
        hideKeyboardOnTap()
        if let packageDetails = packageFilter.packageDetails {
            packageManager = PackageBookingManager(packageDetails: packageDetails)
        }
        
        packageCollectionView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }
    
    func presentDatePicker() {
        let datePickerViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController

        datePickerViewController.pickerTag = 1
        datePickerViewController.delegate = self
        datePickerViewController.minDate = Date().adding(minutes: 1440)
        
        datePickerViewController.modalPresentationStyle = .pageSheet
        
        if let sheet = datePickerViewController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        present(datePickerViewController, animated: true)
    }
    
    func isTravellerDetailsValid() -> Bool {
        var isValid = false
        if packageFilter.startDate == nil {
            self.view.makeToast(Validation.hdyStartDateSelection)
        } else {
            
            let sect = packageManager?.getSection(.primaryTraveller)
            let primary = packageFieldTexts.filter { $0.key == [sect!,0] }
            
            if primary.count == 0 {
                self.view.makeToast(Validation.hdyPrimaryTravellerDetails)
            } else {
                let index = IndexPath(row: 0, section: sect!)
                if primary[index]?.name != "" && primary[index]?.countryCode != "" && primary[index]?.contactNumber != "" && primary[index]?.emailID != "" && primary[index]?.gender != "" && primary[index]?.age != "" {
                    isValid = true
                } else {
                    self.view.makeToast(Validation.hdyPrimaryTravellerDetails)
                }
            }
        }
       
        return isValid
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PackBookingSummaryViewController {
            vc.packBookingData = bookedData
        }
    }
    
    @IBAction func startDateTapped(_ sender: UIButton) {
        presentDatePicker()
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if isTravellerDetailsValid() {
            createBooking()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - APICalls
extension PackageBookingViewController {
    func createBooking() {
        showIndicator()
        
        var guests = [[String: Any]]()
        print(packageFieldTexts)
        let primary = packageFieldTexts.filter { $0.key == [2,0] }
        
        let duration = packageFilter.packageDetails?.durationDays
        
        let bookingTo = packageFilter.startDate?.adding(minutes: 1440 * (duration ?? 0))
        
        
        for each in packageFieldTexts {
            //gender is passed as string to api, and it should be in english
            let gender = K.genders.filter { $0.localized() == each.value.gender }.last ?? ""
            guests.append(["id": 0,
                           "contactNo": each.value.countryCode + each.value.contactNumber,
                           "guestName": each.value.name,
                           "emailId": each.value.emailID,
                           "gender": gender,
                           "isPrimary": each.value == primary.first?.value ? 1 : 0,
                           "age": each.value.age.intValue()])
        }
        
        var params: [String: Any] = ["bookingType": "create",
                                     "bookingDate": Date().stringValue(format: "yyyy-MM-dd"),
                                     "packageId": packageFilter.packageDetails?.packageID ?? 0,
                                     "bookingFrom": packageFilter.startDate!.stringValue(format: "yyyy-MM-dd"),
                                     "bookingTo": bookingTo!.stringValue(format: "yyyy-MM-dd"),
                                     "userId": SessionManager.shared.getLoginDetails()!.userid!,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code,
                                     "booking_Guest": guests,
                                     "adultCount": packageFilter.adult!,
                                     "childCount": packageFilter.child!]
        
        if createdPackageBookingID != nil {
            params["bookingType"] = "update"
            params["bookingId"] = createdPackageBookingID
        }
        parser.sendRequestLoggedIn(url: "api/CustomerHoliday/CreateCustomerHolidayBooking", http: .post, parameters: params) { (result: PackageBookingData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.bookedData = result!.data
                        createdPackageBookingID = result!.data.bookingID
                        self.performSegue(withIdentifier: "toPackBookingSummary", sender: nil)
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
extension PackageBookingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packageManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = packageManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .packageSummary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageSummaryCell", for: indexPath) as! PackageSummaryCollectionViewCell
            
            if let packageDetails = packageManager?.getPackageDetails() {
                cell.setupView()
                let featuredImage = packageDetails.holidayImage.filter { $0.isFeatured == 1}
                if featuredImage.count != 0 {
                    cell.packageImage.sd_setImage(with: URL(string: featuredImage[0].imageURL ?? ""), placeholderImage: UIImage(systemName: K.packagePlaceHolderImage))
                }
                cell.packageName.text = packageDetails.packageName
                cell.locationLabel.text = packageDetails.countryName
                if fontSize == nil {
                    fontSize = cell.packagePrice.font.pointSize
                }
                cell.packagePrice.addPriceString(packageDetails.costPerPerson, packageDetails.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(packageDetails.serviceCharge.attachCurrency) " + "taxes & fee per person".localized()
                
                cell.startDate.text = packageFilter.startDate?.stringValue(format: "dd-MM-yyyy")
            }
            
            
            return cell
        } else if thisSection.type == .header {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageHeaderCell", for: indexPath) as! PackageHeaderCollectionViewCell
            
            
            return cell
        } else if thisSection.type == .primaryTraveller {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryTravellerCell", for: indexPath) as! PrimaryTravellerCollectionViewCell
            
            cell.setupView()
            cell.delegate = self
            cell.cvcDelegate = self
            cell.genderButton.tag = indexPath.section
            cell.primayTravellerField.text = packageFieldTexts[indexPath]?.name
            cell.countryCodeField.text = packageFieldTexts[indexPath]?.countryCode
            cell.contactField.text = packageFieldTexts[indexPath]?.contactNumber
            cell.emailField.text = packageFieldTexts[indexPath]?.emailID
            cell.genderField.text = packageFieldTexts[indexPath]?.gender
            cell.ageField.text = packageFieldTexts[indexPath]?.age
            
            
            return cell
        } else if thisSection.type == .buttons {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageActionCell", for: indexPath) as! PackageActionCollectionViewCell
            
            
            
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}


//MARK: - CollectionViewCellDelegate
extension PackageBookingViewController: CollectionViewCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: UICollectionViewCell) {
        if let indexPath = packageCollectionView.indexPath(for: cell), let text = textField.text {
            if textField.tag == 1 {
                packageFieldTexts[indexPath] = GuestFds(name: text, countryCode: packageFieldTexts[indexPath]?.countryCode ?? "", contactNumber: packageFieldTexts[indexPath]?.contactNumber ?? "", emailID: packageFieldTexts[indexPath]?.emailID ?? "", gender: packageFieldTexts[indexPath]?.gender ?? "", age: packageFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 2 {
                packageFieldTexts[indexPath] = GuestFds(name: packageFieldTexts[indexPath]?.name ?? "", countryCode: packageFieldTexts[indexPath]?.countryCode ?? "", contactNumber: packageFieldTexts[indexPath]?.contactNumber ?? "", emailID: packageFieldTexts[indexPath]?.emailID ?? "", gender: text, age: packageFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 3 {
                packageFieldTexts[indexPath] = GuestFds(name: packageFieldTexts[indexPath]?.name ?? "", countryCode: packageFieldTexts[indexPath]?.countryCode ?? "", contactNumber: packageFieldTexts[indexPath]?.contactNumber ?? "", emailID: packageFieldTexts[indexPath]?.emailID ?? "", gender: packageFieldTexts[indexPath]?.gender ?? "", age: text)
            } else if textField.tag == 4 {
                packageFieldTexts[indexPath] = GuestFds(name: packageFieldTexts[indexPath]?.name ?? "", countryCode: packageFieldTexts[indexPath]?.countryCode ?? "", contactNumber: text, emailID: packageFieldTexts[indexPath]?.emailID ?? "", gender: packageFieldTexts[indexPath]?.gender ?? "", age: packageFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 5 {
                packageFieldTexts[indexPath] = GuestFds(name: packageFieldTexts[indexPath]?.name ?? "", countryCode: packageFieldTexts[indexPath]?.countryCode ?? "", contactNumber: packageFieldTexts[indexPath]?.contactNumber ?? "", emailID: text, gender: packageFieldTexts[indexPath]?.gender ?? "", age: packageFieldTexts[indexPath]?.age ?? "")
            } else if textField.tag == 6 {
                packageFieldTexts[indexPath] = GuestFds(name: packageFieldTexts[indexPath]?.name ?? "", countryCode: text, contactNumber: packageFieldTexts[indexPath]?.contactNumber ?? "", emailID: packageFieldTexts[indexPath]?.emailID ?? "", gender: packageFieldTexts[indexPath]?.gender ?? "", age: packageFieldTexts[indexPath]?.age ?? "")
            }
        }
    }
    
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: UICollectionViewCell) -> Bool {
        return true
    }
    
    func collectionViewCell(deleteTappedFrom cell: UICollectionViewCell) {
        
    }
    
    
}


//MARK: - DynamicCellDelegate
extension PackageBookingViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        packageCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}

//MARK: - DatePickerDelegate
extension PackageBookingViewController: DatePickerDelegate {
    func datePickerDoneTapped(date: Date, tag: Int) {
        packageFilter.startDate = date
        packageCollectionView.reloadSections(IndexSet(integer: packageManager?.getSection(.packageSummary) ?? 0))
    }
}
    


//MARK: - Layout
extension PackageBookingViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.packageManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .packageSummary {
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
                
            } else if thisSection.type == .primaryTraveller {
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
                
            } else if thisSection.type == .buttons {
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

