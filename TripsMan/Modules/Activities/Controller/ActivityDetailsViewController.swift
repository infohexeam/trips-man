//
//  ActivityDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/04/23.
//

import UIKit
import Combine

class ActivityDetailsViewController: UIViewController {
    
    @IBOutlet weak var activityCollectionView: UICollectionView! {
        didSet {
            activityCollectionView.collectionViewLayout = createLayout()
            activityCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            activityCollectionView.dataSource = self
//            activityCollectionView.delegate = self
        }
    }
    
    var activityManager: ActivityDetailsManager?
    var parser = Parser()
    var activityID = 0
    var activityFilters = ActivityFilters()
    
    var fontSize: CGFloat? = nil
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getActivityDetails()
        
    }
}


//MARK: - APICalls
extension ActivityDetailsViewController {
    func getActivityDetails() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerActivity/GetCustomerActivityById?ActivityId=\(activityID)&currency=\(SessionManager.shared.getCurrency())", http: .get, parameters: nil) { (result: ActivityDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.activityManager = ActivityDetailsManager(activityDetails: result!.data)
                        self.activityCollectionView.reloadData()
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
extension ActivityDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activityManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = activityManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityImageCell", for: indexPath) as! ActivityDetailsImageCollectionViewCell
            if let image = activityManager?.getActivityDetails()?.activityImages[indexPath.row] {
                cell.activityImage.sd_setImage(with: URL(string: image.imageURL), placeholderImage: UIImage(systemName: K.activityPlaceholderImage))

            }
            
            return cell
        }  else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
//        case UICollectionView.elementKindSectionHeader:
//            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detailsHeader", for: indexPath) as! PackageDetailsHeaderView
//
//            guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return headerView }
//
//
//            return headerView
            
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "activityFooter", for: indexPath) as! ActivityDetailsFooterView
            
            footerView.configure(with: activityManager?.getActivityDetails()?.activityImages.count ?? 0)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
    
    
}


//MARK: - Layout
extension ActivityDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.activityManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .image {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.6))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: -30, trailing: 8)
                
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }
                    
                    let page = round(offset.x / self.view.bounds.width)
                    
                    self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }
                
                return section
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}



