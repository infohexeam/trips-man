//
//  CouponsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 01/02/23.
//

import UIKit

class CouponsViewController: UIViewController {
    
    @IBOutlet weak var couponField: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.collectionViewLayout = createLayout()
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    enum SectionTypes {
        case list
        case code
    }
    
    struct CouponsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [CouponsSection]? = nil
    
    var coupons = [Coupon]()
    var selectedCoupon: String?
    var bookingID: Int?
    var delegate: CouponDelegate?
    
    let parser = Parser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [CouponsSection(type: .code, count: 1),
                    CouponsSection(type: .list, count: coupons.count)]
        
        
    }
    
}

//MARK: - CouponCodeDelegate
extension CouponsViewController: CouponCodeDelegate {
    func couponCodeDidApplied(couponCode: String) {
        applyCoupon(with: couponCode)
    }
    
    
}


//MARK: - APICalls
extension CouponsViewController {
    func applyCoupon(with couponCode: String) {
        showIndicator()
        
        let params: [String: Any] = ["bookingId": bookingID!,
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
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadData()
                        }
                        self.delegate?.couponDidSelected(coupon: result!.data!.coupon, amountDetails: result!.data!.amounts)
                        self.dismiss(animated: true)
                        
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

//MARK: - UICollectionView

extension CouponsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = sections?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "couponListCell", for: indexPath) as! CouponCollectionViewCell
            
            let coupon = coupons[indexPath.row]
            cell.couponCode.text = coupon.couponCode
            cell.couponDesc.text = "\(coupon.description)\nMin. Order Value: \(coupon.minOrderValue), Discount Amount: \(coupon.discountAmount)"
            
            cell.radioImage.image = UIImage(systemName: "circle")
            
            if selectedCoupon == coupon.couponCode {
                cell.radioImage.image = UIImage(systemName: "circle.fill")
            }
            
            return cell
        } else if thisSection.type == .code {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "couponCodeCell", for: indexPath) as! CouponCodeCollectionViewCell
            
            cell.delegate = self
            
            return cell
        } else {
            fatalError("Unknown section!")
        }
    }
}

extension CouponsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }

        if thisSection.type == .list {
            if selectedCoupon == coupons[indexPath.row].couponCode {
//                selectedCoupon = nil
            } else {
                applyCoupon(with: coupons[indexPath.row].couponCode)
            }
            
        }
    }
}


//MARK: - Layout
extension CouponsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .list {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .code {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
//                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                        heightDimension: .estimated(44))
//                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//
//                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                        heightDimension: .estimated(44))
//                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                section = NSCollectionLayoutSection(group: group)
//                section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 8)
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}


protocol CouponDelegate {
    func couponDidSelected(coupon: Coupon, amountDetails: [AmountDetail])
    func couponRemoved(index: Int)
}
