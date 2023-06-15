//
//  RoomSelectionSummaryViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/09/22.
//

import UIKit

class RoomSelectionSummaryViewController: UIViewController {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    enum SectionTypes {
        case summary
        case primaryGuest
        case otherGuest
        case seperator
        case coupon
        case bottomView
    }
    
    struct SelectionSummarySection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [SelectionSummarySection]? = nil
    var bookedData: CreateBooking? {
        didSet {
            amountDetails = bookedData?.amountDetails
        }
    }
    var amountDetails: [AmountDetail]?
    var coupons = [Coupon]() {
        didSet {
            if coupons.count > K.couponToShow {
                showingCoupons = Array(coupons[...(K.couponToShow-1)])
            } else {
                showingCoupons = coupons
            }
            
        }
    }
    var showingCoupons = [Coupon]() {
        didSet {
            if sections != nil {
                if sections!.contains(where: {$0.type == .coupon} ) {
                    for index in 0..<sections!.count {
                        if sections![index].type == .coupon {
                            sections![index] = SelectionSummarySection(type: .coupon, count: showingCoupons.count)
                        }
                    }
                    UIView.performWithoutAnimation {
                        collectionView.reloadSections(IndexSet(integer: getSection(.coupon)!))
                    }
                } else {
                    sections!.insert(SelectionSummarySection(type: .coupon, count: showingCoupons.count), at: (getSection(.bottomView) ?? (getSection(.bottomView)! - 1)))
                    collectionView.insertSections(IndexSet(integer: (getSection(.bottomView) ?? (getSection(.bottomView)! -  1))))
                    collectionView.reloadSections(IndexSet(integer: getSection(.coupon)!))
                }
            }
        }
    }
    var selectedCoupon: String?
    var rewardPoints: Double = 0
    
    let parser = Parser()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Summary")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        successView.isHidden = true
        
        if let bookedData = bookedData {
            sections = [SelectionSummarySection(type: .summary, count: 1),
                        SelectionSummarySection(type: .primaryGuest, count: 1),
                        SelectionSummarySection(type: .otherGuest, count: bookedData.hotelGuests.filter { $0.isPrimary == 0 }.count),
                        SelectionSummarySection(type: .seperator, count: 1),
                        SelectionSummarySection(type: .coupon, count: 0),
                        SelectionSummarySection(type: .bottomView, count: bookedData.amountDetails.count)]
        }
        
//        sections = [SelectionSummarySection(type: .summary, count: 1),
//                    SelectionSummarySection(type: .primaryGuest, count: 1),
//                    SelectionSummarySection(type: .otherGuest, count: 1),
//                    SelectionSummarySection(type: .seperator, count: 1),
//                    SelectionSummarySection(type: .seperator, count: 1),
//                    SelectionSummarySection(type: .bottomView, count: 1)]
        
        getCoupons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CouponsViewController {
            vc.coupons = self.coupons
            vc.selectedCoupon = selectedCoupon
            vc.bookingID = bookedData!.bookingID
            vc.delegate = self
        } else if let vc = segue.destination as? CheckoutViewController {
            if let data = sender as? CheckoutData {
                vc.checkoutData = data.data
                vc.bookingID = bookedData?.bookingID ?? 0
                vc.listType = .hotel
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
    
    @IBAction func paymentTapped(_ sender: UIButton) {
        checkoutBooking()
    }
    
    @IBAction func applyRewardTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func seeAllCouponsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toCoupons", sender: nil)
    }
    
    @IBAction func returnHomeTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

//MARK: - APICalls

extension RoomSelectionSummaryViewController {
    func getCoupons() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/GetCustomerHotelCouponList?Language=\(SessionManager.shared.getLanguage())&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: CouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.rewardPoints = result!.data.rewardPoint
                        if result!.data.coupon.count > 0 {
                            self.coupons = result!.data.coupon
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
    
    func applyCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": bookedData!.bookingID,
                                     "couponCode": couponCode,
                                     "country": SessionManager.shared.getCountry(),
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/ApplyCustomerHotelCoupen", http: .post, parameters: params) { (result: ApplyCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.selectedCoupon = couponCode
                        self.amountDetails = result!.data!.amounts
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadSections(IndexSet([self.getSection(.coupon)!, self.getSection(.bottomView)!]))
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
    
    func removeCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": bookedData!.bookingID,
                                     "couponCode": couponCode,
                                     "country": SessionManager.shared.getCountry(),
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/RemoveCustomerHotelCoupen", http: .post, parameters: params) { (result: RemoveCouponData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.selectedCoupon = nil
                        if self.coupons.count > K.couponToShow {
                            self.showingCoupons = Array(self.coupons[...(K.couponToShow-1)])
                        } else {
                            self.showingCoupons = self.coupons
                        }
                        self.amountDetails = result!.data
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadSections(IndexSet(integer: self.getSection(.bottomView)!))
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
        let params: [String: Any] = ["bookingId": bookedData?.bookingID ?? 0,
                                     "country": SessionManager.shared.getCountry(),
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage()]
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/CustomerHotelCheckOut", http: .post, parameters: params) { (result: CheckoutData?, error) in
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

//MARK: - Coupon Delegate
extension RoomSelectionSummaryViewController: CouponDelegate {
    func couponDidSelected(coupon: Coupon, amountDetails: [AmountDetail]) {
        self.selectedCoupon = coupon.couponCode
        self.showingCoupons = [coupon]
        self.amountDetails = amountDetails
        self.collectionView.reloadSections(IndexSet(integer: self.getSection(.bottomView)!))
    }
    
    func couponRemoved(index: Int) {
        removeCoupon(with: coupons[index].couponCode)
    }

}

//MARK: - CollectionView

extension RoomSelectionSummaryViewController: UICollectionViewDataSource {
    
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookSummaryCell", for: indexPath) as! BookSummaryCollectionViewCell
            
            if let bookedData = bookedData {
                cell.checkinLabel.text = bookedData.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy")
                cell.checkoutLabel.text = bookedData.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy")
                cell.hotelName.text = bookedData.hotelDetails.hotelName
                cell.hotelImage.sd_setImage(with: URL(string: bookedData.imageUrl ?? ""), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
                cell.roomType.text = bookedData.roomDetails[0].roomType
                cell.addressLabel.text = bookedData.hotelDetails.address.capitalizedSentence
                let roomAndGuestCount = "\(bookedData.roomCount.oneOrMany("Room")) for \(bookedData.adultCount.oneOrMany("Adult")) and \(bookedData.childCount.oneOrMany("Child", suffix: "ren"))"
                cell.guestLabel.text = roomAndGuestCount
            }
            
            return cell
        } else if thisSection.type == .primaryGuest {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "primaryGuestCell", for: indexPath) as! PrimaryGuestCollectionViewCell
            if let bookedData = bookedData {
                cell.nameLabel.text = bookedData.primaryGuest
                cell.numberLabel.text = bookedData.contactNo
                cell.ageAndGender.text = bookedData.gender + ", \(bookedData.age)"
                cell.emailLabel.text = bookedData.emailID
            }
            
            return cell
        } else if thisSection.type == .otherGuest {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherGuestCell", for: indexPath) as! OtherGuestCollectionViewCell
            
            if let otherGuests = bookedData?.hotelGuests.filter({ $0.isPrimary == 0 }) {
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
            
            let coupon = showingCoupons[indexPath.row]
            cell.couponCode.text = coupon.couponCode
            cell.couponDesc.text = "\(coupon.description)\nMin. Order Value: \(coupon.minOrderValue), Discount Amount: \(coupon.discountAmount)"
            
            cell.radioImage.image = UIImage(systemName: "circle")
            cell.removeButton.isHidden = true
            
            if selectedCoupon == coupon.couponCode {
                cell.radioImage.image = UIImage(systemName: "circle.circle.fill")
                cell.removeButton.isHidden = false
            }
            
            
            return cell
        }  else if thisSection.type == .bottomView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            if let amountDetails = amountDetails {
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
            fatalError("Unknown section!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! HotelDetailsHeaderView
            
            guard let thisSection = sections?[indexPath.section] else { return headerView }
            
            if thisSection.type == .primaryGuest {
                headerView.titleLabel.text = "Primary Guest"
            } else if thisSection.type == .otherGuest {
                headerView.titleLabel.text = "Other Guests"
            } else if thisSection.type == .coupon {
                headerView.titleLabel.text = "Coupon Codes"
            }
            
            return headerView
           
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooter", for: indexPath) as! CouponFooterView
            
            guard let thisSection = sections?[indexPath.section] else { return footerView }
            if thisSection.type == .coupon {
                if coupons.count > showingCoupons.count {
                    footerView.footerButton.setTitle("See all coupons (\(coupons.count))", for: .normal)
                } else {
                    footerView.footerButton.setTitle("Have a coupon code?", for: .normal)
                }
                footerView.footerButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 15)
                
            }
            
            return footerView
        default:
            return UICollectionReusableView()
//            assert(false, "Invalid Element Type")
        }
    }
    
}

extension RoomSelectionSummaryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .coupon {
            if selectedCoupon != showingCoupons[indexPath.row].couponCode {
                applyCoupon(with: showingCoupons[indexPath.row].couponCode)
            }
            
        }
    }
}


extension RoomSelectionSummaryViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
//            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .summary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(230))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            
            } else if thisSection.type == .primaryGuest {
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
            } else if thisSection.type == .otherGuest {
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
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
            } else if thisSection.type == .coupon {
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
            }  else if thisSection.type == .bottomView {
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

