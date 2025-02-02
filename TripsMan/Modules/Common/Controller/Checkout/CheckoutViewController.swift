//
//  CheckoutViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 30/05/23.
//

import UIKit
import Razorpay

class CheckoutViewController: UIViewController {
    
    @IBOutlet weak var checkoutCollectionView: UICollectionView! {
        didSet {
            checkoutCollectionView.collectionViewLayout = createLayout()
            checkoutCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            checkoutCollectionView.dataSource = self
        }
    }
    
    var checkoutManager: CheckoutManager?
    var checkoutData: Checkout?
    var bookingID = 0
    var listType: ListType?
    
    let parser = Parser()
    
    var rewardApplied = false
    
    var razorpay: RazorpayCheckout!
    var paymentOrderId: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vc = self.navigationController?.viewControllers
        if let vc = vc {
            addBackButton(with: "Checkout".localized(), toVc: vc.count-3)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let checkoutData = checkoutData {
            checkoutManager = CheckoutManager(checkoutData: checkoutData, amounts: nil)
            checkoutCollectionView.reloadData()

        }
    }
    
    @IBAction func rewardButtonTapped(_ sender: UIButton) {
        if !rewardApplied {
            applyRewardPoint()
        } else {
            removeRewardPoint()
        }
        
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        if let paymentOrderId = paymentOrderId {
            openRazorPay(with: paymentOrderId)
        } else {
            createPaymentOrder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SuccessViewController {
            if let response = sender as? [AnyHashable: Any] {
                vc.paymentResponse = response
                vc.bookingID = bookingID
                vc.listType = listType
            }
        }
    }

}

//MARK: - APICalls
extension CheckoutViewController {
    
    func applyRewardPoint() {
        showIndicator()
        
        var url = ""
        if let listType = listType {
            switch listType {
            case .hotel:
                url = "api/CustomerHotelBooking/ApplyCustomerHotelRewardPoint"
            case .packages:
                url = "api/CustomerHolidayCoupon/ApplyCustomerHolidayRewardPoint"
            case .activities:
                url = "api/CustomerActivityCoupon/ApplyCustomerActivityRewardPoint"
            case .meetups:
                url = "api/CustomerMeetupCoupon/ApplyCustomerMeetupRewardPoint"
            }
        }
        
        let params: [String: Any] = ["bookingId": bookingID,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        
        parser.sendRequestLoggedIn(url: url, http: .post, parameters: params) { (result: RewardPointsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        let checkout = self.checkoutManager?.getCheckoutDetails()
                        self.checkoutManager = CheckoutManager(checkoutData: checkout, amounts: result!.data)
                        self.rewardApplied = true
                        self.checkoutCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
    
    func removeRewardPoint() {
        showIndicator()
        
        var url = ""
        if let listType = listType {
            switch listType {
            case .hotel:
                url = "api/CustomerCoupon/RemoveCustomerHotelRewardPoint"
            case .packages:
                url = "api/CustomerHolidayCoupon/RemoveCustomerHolidayRewardPoint"
            case .activities:
                url = "api/CustomerActivityCoupon/RemoveCustomerActivityRewardPoint"
            case .meetups:
                url = "api/CustomerMeetupCoupon/RemoveCustomerMeetupRewardPoint"
            }
        }
        
        let params: [String: Any] = ["bookingId": bookingID,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        
        parser.sendRequestLoggedIn(url: url, http: .post, parameters: params) { (result: RewardPointsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        let checkout = self.checkoutManager?.getCheckoutDetails()
                        self.checkoutManager = CheckoutManager(checkoutData: checkout, amounts: result!.data)
                        self.rewardApplied = false
                        self.checkoutCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
    
    
    func createPaymentOrder() {
        self.showIndicator()
        let params: [String: Any] = ["bookingId": bookingID,
                                     "moduleCode": K.getModuleCode(of: listType ?? .hotel)]
        
        parser.sendRequestLoggedIn(url: "api/Payment/CreateOrder", http: .post, parameters: params) { (result: PaymentData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.paymentOrderId = result!.data
                        self.openRazorPay(with: result!.data)
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

//MARK: - UICollectionView
extension CheckoutViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return checkoutManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = checkoutManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = checkoutManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            if let amount = checkoutManager?.getAmountDetails()?[indexPath.row] {
                cell.alignValueLabel()
                cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                
                cell.keyLabel.text = amount.label
                cell.valueLabel.text = amount.amount.attachCurrency
                cell.seperator.isHidden = true
                
                if amount.isTotalAmount == 1 {
                    cell.seperator.isHidden = false
                    cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                    cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                }
            }
            
            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seperatorCell", for: indexPath) as! SeperatorCell
            
            return cell
        } else if thisSection.type == .paymentMethod {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentMethodCell", for: indexPath) as! PaymentMethodCollectionViewCell
            
            return cell
        }  else if thisSection.type == .reward {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rewardCell", for: indexPath) as! CheckoutRewardCollectionViewCell
            if let details = checkoutManager?.getCheckoutDetails() {
                cell.rewardView.isHidden = true
                
                if details.customerPoints > 0 {
                    cell.rewardView.isHidden = false
                    cell.rewardButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
                    cell.rewardButton.setImage(UIImage(systemName: "square"), for: .normal)
                    cell.rewardButton.isSelected = self.rewardApplied
                    
                    cell.rewardText.text = L.redeemRewardPointText(percentage: details.redeamPercentage, maxAmount: details.maximumRedeamAmount)
                }
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}


//MARK: - Layout
extension CheckoutViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.checkoutManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .priceDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(4))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(4))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .paymentMethod {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .reward {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

