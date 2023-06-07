//
//  PackageDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/03/23.
//

import UIKit
import Combine

class PackageDetailsViewController: UIViewController {
    
    @IBOutlet weak var packageCollectionView: UICollectionView! {
        didSet {
            packageCollectionView.collectionViewLayout = createLayout()
            packageCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            packageCollectionView.dataSource = self
            packageCollectionView.delegate = self
        }
    }
    
    var packageManager: PackageDetailsManager?
    var parser = Parser()
    var packageID = 0
    var packageFilters = PackageFilters()
    
    var fontSize: CGFloat? = nil
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Package Details")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPackageDetails()
    }
    
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        if SessionManager.shared.getLoginDetails() == nil {
            tabBarDelegate?.switchTab(0)
            tabBarDelegate?.presentVC("toLogin")
        } else {
            performSegue(withIdentifier: "toPackageBooking", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PackageBookingViewController {
            packageFilters.packageDetails = packageManager?.getPackageDetails()
            vc.packageFilter = packageFilters
        }
    }

}


//MARK: - APICalls
extension PackageDetailsViewController {
    func getPackageDetails() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHoliday/GetCustomerHolidayPackageById?packageId=\(packageID)&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: PackageDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.packageManager = PackageDetailsManager(packageDetails: result!.data)
                        self.packageCollectionView.reloadData()
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
extension PackageDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return packageManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = packageManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageImageCell", for: indexPath) as! PackageImageCollectionViewCell
            if let image = packageManager?.getPackageDetails()?.holidayImage[indexPath.row] {
                cell.packageImage.sd_setImage(with: URL(string: image.imageURL ?? ""), placeholderImage: UIImage(systemName: K.packagePlaceHolderImage))

            }
            
            return cell
        } else if thisSection.type == .packageDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "packageDetailsCell", for: indexPath) as! PackageDetailsCollectionViewCell
            
            if let packageDetails = packageManager?.getPackageDetails() {
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                
                cell.packageName.text = packageDetails.packageName + " ksldmald " + packageDetails.packageName
                cell.priceLabel.addPriceString(packageDetails.costPerPerson, packageDetails.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(SessionManager.shared.getCurrency()) \(packageDetails.serviceCharge) taxes and fee per person"
            }
            
            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "separator", for: indexPath) as! SeperatorCell
            
            return cell
        } else if thisSection.type == .vendorDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "vendorDetailsCell", for: indexPath) as! VendorDetailsCollectionViewCell
            
            if let vendorDetails = packageManager?.getPackageDetails()?.holidayVendor {
                cell.vendorName.text = vendorDetails.vendorName
                cell.vendorEmail.text = vendorDetails.vendorEmail
                cell.vendorMobile.text = vendorDetails.vendorMobile
            }
            
            return cell
        } else if thisSection.type == .itinerary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itineraryCell", for: indexPath) as! PackageItineraryCollectionViewCell
            if let itinerary = packageManager?.getPackageDetails()?.holidayItinerary[indexPath.row] {
                cell.itineraryImage.sd_setImage(with: URL(string: itinerary.image), placeholderImage: UIImage(systemName: K.packagePlaceHolderImage))
                cell.itineraryName.text = itinerary.itineryName
                cell.itineraryDescription.text = itinerary.itineryDescription
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detailsHeader", for: indexPath) as! PackageDetailsHeaderView
            
            guard let thisSection = packageManager?.getSections()?[indexPath.section] else { return headerView }
            
            if thisSection.type == .itinerary {
                headerView.titleLabel.text = "Itinerary"
            } else if thisSection.type == .vendorDetails {
                headerView.titleLabel.text = "Vendor"
            }
            return headerView
            
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "packageDetailsFooter", for: indexPath) as! PackageDetailsFooterView
            
            footerView.configure(with: packageManager?.getPackageDetails()?.holidayImage.count ?? 0)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
        default:
            return UICollectionReusableView()
            //            assert(false, "Invalid Element Type")
        }
    }
    
    
}

extension PackageDetailsViewController: UICollectionViewDelegate {
    
}


//MARK: - Layout
extension PackageDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.packageManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .image {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.6))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionFooter]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: -30, trailing: 0)
                
                
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }
                    
                    let page = round(offset.x / self.view.bounds.width)
                    
                    self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }
                
                return section
                
            } else if thisSection.type == .packageDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
                
                return section
                
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
            } else if thisSection.type == .vendorDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .absolute(30))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
                return section
                
            } else if thisSection.type == .itinerary {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(30))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(30))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                          heightDimension: .absolute(30))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
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


