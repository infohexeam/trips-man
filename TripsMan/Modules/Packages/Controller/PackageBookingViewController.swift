//
//  PackageBookingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 24/03/23.
//

import UIKit

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
    
    var packageDetails: PackageDetails?
    var fontSize: CGFloat? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        if let packageDetails = packageDetails {
            packageManager = PackageBookingManager(packageDetails: packageDetails)
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
            
            print("ggkbjlkk")
            if let packageDetails = packageManager?.getPackageDetails() {
                let featuredImage = packageDetails.holidayImage.filter { $0.isFeatured == 1}
                if featuredImage.count != 0 {
                    cell.packageImage.sd_setImage(with: URL(string: featuredImage[0].imageURL ?? ""), placeholderImage: UIImage(systemName: K.packagePlaceHolderImage))
                }
                cell.packageName.text = packageDetails.packageName
                if fontSize == nil {
                    fontSize = cell.packagePrice.font.pointSize
                }
                cell.packagePrice.addPriceString(packageDetails.costPerPerson, packageDetails.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(SessionManager.shared.getCurrency()) \(packageDetails.seviceCharge) taxes and fee per person"
//                cell.dateLabel.text
                
            }
            
            
            return cell
        }  else {
            return UICollectionViewCell()
        }
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
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

