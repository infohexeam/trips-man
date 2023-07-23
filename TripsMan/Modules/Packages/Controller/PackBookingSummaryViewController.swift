//
//  PackBookingSummaryViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/04/23.
//

import UIKit

class PackBookingSummaryViewController: UIViewController {
    
    @IBOutlet weak var summaryCollectionView: UICollectionView! {
        didSet {
            summaryCollectionView.collectionViewLayout = createLayout()
            summaryCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            summaryCollectionView.dataSource = self
            summaryCollectionView.delegate = self
        }
    }
    
    var packageManager: PackageSummaryManager?
    var parser = Parser()
    
    var packBookingData: PackageBooking?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        packageManager = PackageSummaryManager(packagbooking: packBookingData)
        getCoupons()
        
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
            vc.coupons = (packageManager?.getAllCoupons())!
            vc.selectedCoupon = packageManager?.getSelectedCoupon()
            vc.bookingID = packBookingData!.bookingID
            vc.couponModule = .holiday
            vc.delegate = self
        } else if let vc = segue.destination as? CheckoutViewController {
            if let data = sender as? CheckoutData {
                vc.checkoutData = data.data
                vc.bookingID = packBookingData?.bookingID ?? 0
                vc.listType = .packages
            }
        }
    }

}

//MARK: - APICalls
extension PackBookingSummaryViewController {
    func getCoupons() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHolidayCoupon/GetCustomerHolidayCouponList?Language=\(SessionManager.shared.getLanguage().code)&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: CouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.packageManager = PackageSummaryManager(packageBooking: self.packBookingData, coupons: result!.data.coupon, rewardPoints: result!.data.rewardPoint)
                        self.summaryCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
    
    func applyCoupon(with coupon: Coupon) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": packBookingData!.bookingID,
                                     "couponCode": coupon.couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        
        parser.sendRequestLoggedIn(url: "api/CustomerHolidayCoupon/ApplyCustomerHolidayCoupen", http: .post, parameters: params) { (result: ApplyCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.packageManager?.setSelectedCoupon(coupon, amountDetails: result!.data!.amounts)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.packageManager!.getSection(.coupon)!, self.packageManager!.getSection(.bottomView)!]))
                        }
                        
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
    
    func removeCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": packBookingData!.bookingID,
                                     "couponCode": couponCode,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        
        parser.sendRequestLoggedIn(url: "api/CustomerHolidayCoupon/RemoveCustomerHolidayCoupen", http: .post, parameters: params) { (result: RemoveCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.packageManager?.setSelectedCoupon(nil, amountDetails: result!.data)
                        UIView.performWithoutAnimation {
                            self.summaryCollectionView.reloadSections(IndexSet([self.packageManager!.getSection(.coupon)!, self.packageManager!.getSection(.bottomView)!]))
                        }
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
    
    func checkoutBooking() {
        showIndicator()
        let params: [String: Any] = ["bookingId": packBookingData?.bookingID ?? 0,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/CustomerHolidayCheckOut", http: .post, parameters: params) { (result: CheckoutData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.performSegue(withIdentifier: "toCheckout", sender: result)
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
extension PackBookingSummaryViewController: UICollectionViewDataSource {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packBookingSummaryCell", for: indexPath) as! PackBookingSummaryCollectionViewCell
            if let packageDetails = packageManager?.getPackageDetails() {
                cell.packageName.text = packageDetails.packageName
                cell.country.text = packageDetails.countryName
                
                if let booking = packageManager?.getBookingSummary() {
                    cell.duration.text = "\(getDateRange(from: booking.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss") ?? Date(), to: booking.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss") ?? Date())) - \(packageDetails.duration)"
                    
                    let vendor = booking.vendorDetails
                    cell.vendorName.text = vendor.vendorName
                }
            }
            
            
            
            return cell
        } else if thisSection.type == .primaryTraveller {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryGuestCell", for: indexPath) as! PrimaryGuestCollectionViewCell
            if let primaryTraveller = packageManager?.bookingData?.holidayGuests.filter({ $0.isPrimary == 1 }).last {
                cell.nameLabel.text = primaryTraveller.guestName
                cell.numberLabel.text = primaryTraveller.contactNo
                cell.ageAndGender.text = primaryTraveller.gender + ", \(primaryTraveller.age)"
                cell.emailLabel.text = primaryTraveller.email
            }
            
            
            return cell
        } else if thisSection.type == .otherTravellers {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherGuestCell", for: indexPath) as! OtherGuestCollectionViewCell
            
            if let otherGuests = packageManager?.bookingData?.holidayGuests.filter({ $0.isPrimary == 0 }) {
                cell.nameLabel.text = "\(indexPath.row+1). \(otherGuests[indexPath.row].guestName)"
                cell.ageAndGender.text = "\(otherGuests[indexPath.row].gender), \(otherGuests[indexPath.row].age)"
            }
            
            
            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seperatorCell", for: indexPath) as! SeperatorCell
            
            
            return cell
        } else if thisSection.type == .coupon {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "couponCell", for: indexPath) as! CouponCollectionViewCell
            
            cell.delegate = self
            cell.removeButton.tag = indexPath.row
            
            if let coupon = packageManager?.getCouponsToShow()?[indexPath.row] {
                cell.couponCode.text = coupon.couponCode
                cell.couponDesc.text = K.getCouponText(with: coupon.description, minAmount: coupon.minOrderValue, discount: coupon.discountAmount, discountType: coupon.discountType)
                
                cell.radioImage.image = UIImage(systemName: "circle")
                cell.removeButton.isHidden = true
                
                if packageManager?.getSelectedCoupon() == coupon.couponCode {
                    cell.radioImage.image = UIImage(systemName: "circle.circle.fill")
                    cell.removeButton.isHidden = false
                }
            }
            
            
            return cell
        }  else if thisSection.type == .bottomView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            if let amountDetails = packageManager?.getAmountDetails() {
                cell.alignValueLabel()
                cell.paymentButton.isHidden = true
                cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                
                let amount = amountDetails[indexPath.row]
                cell.keyLabel.text = amount.label
                cell.valueLabel.text = amount.amount.attachCurrency
                
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
            
            guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return headerView }
            
            if thisSection.type == .primaryTraveller {
                headerView.headerLabel.text = "Primary Traveller".localized()
            } else if thisSection.type == .otherTravellers {
                headerView.headerLabel.text = "Other Travellers".localized()
            } else if thisSection.type == .coupon {
                headerView.headerLabel.text = "Coupon Codes".localized()
            }
            
            return headerView
           
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooter", for: indexPath) as! CouponFooterView
            
            guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return footerView }
            if thisSection.type == .coupon {
                if packageManager!.coupons!.count > packageManager!.getCouponsToShow()!.count {
                    let title = "See all coupons".localized() + " packageManager!.coupons!.count"
                    footerView.footerButton.setTitle(title, for: .normal)
                } else {
                    footerView.footerButton.setTitle("Have a coupon code?".localized(), for: .normal)
                }
                footerView.footerButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15)
                
            }
            
            return footerView
    
        default:
            return UICollectionReusableView()
        }
    }
    
}

extension PackBookingSummaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return }
        
        if thisSection.type == .coupon {
            if packageManager?.getSelectedCoupon() != packageManager?.getCouponsToShow()?[indexPath.row].couponCode {
                applyCoupon(with: (packageManager?.getCouponsToShow()?[indexPath.row])!)
            }
            
        }
    }
}


//MARK: - CouponDelegate
extension PackBookingSummaryViewController: CouponDelegate {
    func couponDidSelected(coupon: Coupon, amountDetails: [AmountDetail]) {
        packageManager?.setSelectedCoupon(coupon, amountDetails: amountDetails, showSingleCoupon: true)
        self.summaryCollectionView.reloadSections(IndexSet([self.packageManager!.getSection(.coupon)!, self.packageManager!.getSection(.bottomView)!]))
    }
    
    func couponRemoved(index: Int) {
        if let coupon = packageManager?.getCouponsToShow()?[index] {
            removeCoupon(with: coupon.couponCode)
        }
    }
    
}


//MARK: - Layout
extension PackBookingSummaryViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.packageManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .packageSummary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if thisSection.type == .primaryTraveller || thisSection.type == .otherTravellers {
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
            }   else if thisSection.type == .coupon {
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
            } else if thisSection.type == .bottomView {
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
