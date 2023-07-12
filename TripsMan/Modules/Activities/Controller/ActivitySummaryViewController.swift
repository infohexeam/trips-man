//
//  ActivitySummaryViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/04/23.
//

import UIKit

class ActivitySummaryViewController: UIViewController {
    
    
    @IBOutlet weak var summaryCollectionView: UICollectionView! {
        didSet {
            summaryCollectionView.collectionViewLayout = createLayout()
            summaryCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            summaryCollectionView.dataSource = self
            summaryCollectionView.delegate = self
        }
    }
    
    var listType: ListType?
    
    var activityManager: ActivitySummaryManager?
    var parser = Parser()
    
    var activityBookingData: ActivityBooking?
    var meetupBookingData: MeetupBooking?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var title = ""
        if listType == .activities {
            title = "Activity Booking Summary"
        } else if listType == .meetups {
            title = "Meetup Booking Summary"
        }
        addBackButton(with: title)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityManager = ActivitySummaryManager(activityBooking: activityBookingData, meetupBooking: meetupBookingData)
        
        if listType == .activities {
            getActivityCoupons()
        } else if listType == .meetups {
            getMeetupCoupons()
        }
    }
    
    @IBAction func paymentButtonTapped(_ sender: UIButton) {
        checkoutBooking()
    }
    
    @IBAction func returnHomeTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func seeAllCouponsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCoupons", sender: nil)
    }
    
    @IBAction func applyrewardButtonTapped(_sender: UIButton) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CouponsViewController {
            vc.coupons = (activityManager?.getAllCoupons())!
            vc.selectedCoupon = activityManager?.getSelectedCoupon()
            if listType == .activities {
                vc.bookingID = activityBookingData!.bookingId
                vc.couponModule = .activity
            } else if listType == .meetups {
                vc.bookingID = meetupBookingData!.bookingId
                vc.couponModule = .meetup
            }
            vc.delegate = self
        } else if let vc = segue.destination as? CheckoutViewController {
            if let data = sender as? CheckoutData {
                vc.checkoutData = data.data
                vc.listType = listType
                if listType == .activities {
                    vc.bookingID = activityManager?.getActivityBookingSummary()?.bookingId ?? 0
                } else if listType == .meetups {
                    vc.bookingID = activityManager?.getMeetupBookingSummary()?.bookingId ?? 0
                }
                
            }
        }
    }
}

//MARK: - APICalls
extension ActivitySummaryViewController {
    func getActivityCoupons() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerActivityCoupon/GetCustomerActivityCouponList?Language=\(SessionManager.shared.getLanguage())&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: CouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager = ActivitySummaryManager(activityBooking: self.activityBookingData, meetupBooking: self.meetupBookingData, coupons: result!.data.coupon, rewardPoints: result!.data.rewardPoint)
                        self.summaryCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getMeetupCoupons() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerMeetupCoupon/GetCustomerMeetupCouponList?Language=\(SessionManager.shared.getLanguage())&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: CouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager = ActivitySummaryManager(activityBooking: self.activityBookingData, meetupBooking: self.meetupBookingData, coupons: result!.data.coupon, rewardPoints: result!.data.rewardPoint)
                        self.summaryCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func applyActivityCoupon(with coupon: Coupon) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": activityBookingData!.bookingId,
                                     "couponCode": coupon.couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerActivityCoupon/ApplyCustomerActivityCoupen", http: .post, parameters: params) { (result: ApplyCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager?.setSelectedCoupon(coupon, amountDetails: result!.data!.amounts)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.activityManager!.getSection(.coupon)!, self.activityManager!.getSection(.priceDetails)!]))
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
    
    func applyMeetupCoupon(with coupon: Coupon) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": meetupBookingData!.bookingId,
                                     "couponCode": coupon.couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerMeetupCoupon/ApplyCustomerMeetupCoupen", http: .post, parameters: params) { (result: ApplyCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager?.setSelectedCoupon(coupon, amountDetails: result!.data!.amounts)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.activityManager!.getSection(.coupon)!, self.activityManager!.getSection(.priceDetails)!]))
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
    
    func removeActivityCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": activityBookingData!.bookingId,
                                     "couponCode": couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerActivityCoupon/RemoveCustomerActivityCoupen", http: .post, parameters: params) { (result: RemoveCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager?.setSelectedCoupon(nil, amountDetails: result!.data)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.activityManager!.getSection(.coupon)!, self.activityManager!.getSection(.priceDetails)!]))
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
    
    func removeMeetupCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": meetupBookingData!.bookingId,
                                     "couponCode": couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerMeetupCoupon/RemoveCustomerMeetupCoupen", http: .post, parameters: params) { (result: RemoveCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager?.setSelectedCoupon(nil, amountDetails: result!.data)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.activityManager!.getSection(.coupon)!, self.activityManager!.getSection(.priceDetails)!]))
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
    
    func checkoutBooking() {
        showIndicator()
        
        var bookingId = 0
        var url = ""
        if listType == .activities {
            bookingId = activityManager?.getActivityBookingSummary()?.bookingId ?? 0
            url = "api/CustomerCoupon/CustomerActivityCheckOut"
        } else if listType == .meetups {
            bookingId = activityManager?.getMeetupBookingSummary()?.bookingId ?? 0
            url = "api/CustomerCoupon/CustomerMeetupCheckOut"
        }
        
        let params: [String: Any] = ["bookingId": bookingId,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        parser.sendRequestLoggedIn(url: url, http: .post, parameters: params) { (result: CheckoutData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.performSegue(withIdentifier: "toCheckout", sender: result)
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
extension ActivitySummaryViewController: UICollectionViewDataSource {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityBookSummaryCell", for: indexPath) as! ActivityBookSummaryCollectionViewCell
            if let activityBooking = activityManager?.getActivityBookingSummary() {
                cell.nameKeyLabel.text = "Activity Name"
                cell.activityName.text = activityBooking.activityName
                cell.dateKeyLabel.text = "Activity Date"
                cell.activityDate.text = activityBooking.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy")
                cell.guestKeyLabel.text = "Total Customers"
                cell.guestsLabel.text = activityBooking.adultCount.stringValue()
                cell.locationKeyLabel.text = "Location"
                cell.locationLabel.text = activityBooking.location
                
                
            } else if let meetupBooking = activityManager?.getMeetupBookingSummary() {
                cell.nameKeyLabel.text = "Meetup Name"
                cell.activityName.text = meetupBooking.meetupName
                cell.dateKeyLabel.text = "Activity Date"
                cell.activityDate.text = meetupBooking.meetupDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy")
                cell.guestKeyLabel.text = "Total Customers"
                cell.guestsLabel.text = meetupBooking.adultCount.stringValue()
                cell.locationKeyLabel.text = "Location"
                cell.locationLabel.text = meetupBooking.address
                
            }
                        
            return cell
        } else if thisSection.type == .customerDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCustomerCell", for: indexPath) as! PrimaryGuestCollectionViewCell
                if let activityCustomer = activityManager?.activityBookingData?.activityGuests.filter({ $0.isPrimary == 1 }).last {
                    cell.nameLabel.text = activityCustomer.guestName
                    cell.numberLabel.text = activityCustomer.contactNo
                    cell.ageAndGender.text = activityCustomer.gender + ", \(activityCustomer.age)"
                    cell.emailLabel.text = activityCustomer.email
                } else if let meetupCustomer = activityManager?.meetupBookingData?.meetupGuests.filter({ $0.isPrimary == 1 }).last {
                    cell.nameLabel.text = meetupCustomer.guestName
                    cell.numberLabel.text = meetupCustomer.contactNo
                    cell.ageAndGender.text = meetupCustomer.gender + ", \(meetupCustomer.age)"
                    cell.emailLabel.text = meetupCustomer.email
                }
            
            
            
            
            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seperatorCell", for: indexPath) as! SeperatorCell
            
            
            return cell
        } else if thisSection.type == .coupon {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "couponCell", for: indexPath) as! CouponCollectionViewCell
            
            cell.delegate = self
            cell.removeButton.tag = indexPath.row
            
            if let coupon = activityManager?.getCouponsToShow()?[indexPath.row] {
                cell.couponCode.text = coupon.couponCode
                cell.couponDesc.text = K.getCouponText(with: coupon.description, minAmount: coupon.minOrderValue, discount: coupon.discountAmount, discountType: coupon.discountType)
                
                cell.radioImage.image = UIImage(systemName: "circle")
                cell.removeButton.isHidden = true
                
                if activityManager?.getSelectedCoupon() == coupon.couponCode {
                    cell.radioImage.image = UIImage(systemName: "circle.circle.fill")
                    cell.removeButton.isHidden = false
                }
            }
            
            
            return cell
        } else if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            if let amountDetails = activityManager?.getAmountDetails() {
                cell.paymentButton.isHidden = true
                cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                
                let amount = amountDetails[indexPath.row]
                cell.keyLabel.text = amount.label
                cell.valueLabel.text = "\(SessionManager.shared.getCurrency()) \(amount.amount)"
                
                if amount.isTotalAmount == 1 {
                    cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                    cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                }
                
                if indexPath.row == amountDetails.count - 1 {
                    cell.paymentButton.isHidden = false
                }
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! PackageSummaryHeadereView
            
            guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return headerView }
            
            if thisSection.type == .customerDetails {
                headerView.headerLabel.text = "Customer Details"
            } else if thisSection.type == .coupon {
                headerView.headerLabel.text = "Coupon Codes"
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooter", for: indexPath) as! CouponFooterView
            
            guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return footerView }
            if thisSection.type == .coupon {
                if activityManager!.coupons!.count > activityManager!.getCouponsToShow()!.count {
                    footerView.footerButton.setTitle("See all coupons (\(activityManager!.coupons!.count))", for: .normal)
                } else {
                    footerView.footerButton.setTitle("Have a coupon code?", for: .normal)
                }
                footerView.footerButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15)
                
            }
            
            return footerView
            
        default:
            return UICollectionReusableView()
        }
    }
    
}

extension ActivitySummaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return }
        
        if thisSection.type == .coupon {
            if activityManager?.getSelectedCoupon() != activityManager?.getCouponsToShow()?[indexPath.row].couponCode {
                if listType == .activities {
                    applyActivityCoupon(with: (activityManager?.getCouponsToShow()?[indexPath.row])!)
                } else if listType == .meetups {
                    applyMeetupCoupon(with: (activityManager?.getCouponsToShow()?[indexPath.row])!)
                }
            }
            
        }
    }
}


//MARK: - CouponDelegate
extension ActivitySummaryViewController: CouponDelegate {
    func couponDidSelected(coupon: Coupon, amountDetails: [AmountDetail]) {
        activityManager?.setSelectedCoupon(coupon, amountDetails: amountDetails, showSingleCoupon: true)
        self.summaryCollectionView.reloadSections(IndexSet([self.activityManager!.getSection(.coupon)!, self.activityManager!.getSection(.priceDetails)!]))
    }
    
    func couponRemoved(index: Int) {
        if let coupon = activityManager?.getCouponsToShow()?[index] {
            if listType == .activities {
                removeActivityCoupon(with: coupon.couponCode)
            } else if listType == .meetups {
                removeMeetupCoupon(with: coupon.couponCode)
            }
        }
    }
    
}


//MARK: - Layout
extension ActivitySummaryViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let thisSection = self.activityManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .summary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if thisSection.type == .customerDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 10, trailing: 8)
            }  else if thisSection.type == .coupon {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 8)
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
            } else if thisSection.type == .priceDetails {
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
}

