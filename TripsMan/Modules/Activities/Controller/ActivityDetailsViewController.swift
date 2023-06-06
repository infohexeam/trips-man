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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Activity Details")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getActivityDetails()
        
    }
    
    @IBAction func bookNowTapped(_ sender: UIButton) {
        if activityFilters.activityDate != nil {
            performSegue(withIdentifier: "toActivityBooking", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? ReadMoreViewController {
                if let content = sender as? String {
                    vc.readMoreContent = content
                }
            }
            
        } else  if let vc = segue.destination as? ActivityBookingViewController {
            activityFilters.activityDetails = activityManager?.getActivityDetails()
            vc.activityFilters = activityFilters
            vc.listType = .activities
        }
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
        } else if thisSection.type == .activityDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityDetailsCell", for: indexPath) as! ActivityDetailsCollectionViewCell
            
            if let details = activityManager?.getActivityDetails() {
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                
                cell.activityName.text = details.activityName
                cell.priceLabel.addPriceString(details.costPerPerson, details.offerPrice, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(SessionManager.shared.getCurrency()) \(details.serviceChargeValue) taxes and fee per person"
                cell.detailsLabel.text = details.shortDescription
                cell.dateLabel.text = activityFilters.activityDate?.stringValue(format: "dd MMM yyyy")
            }
            
            return cell
        } else if thisSection.type == .description {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! ActivityDescriptionCollectionViewCell
            
            if let description = activityManager?.getDescription() {
                cell.descTitle.text = description[indexPath.row].title
                cell.descDetails.attributedText = description[indexPath.row].description.attributedHtmlString
                cell.delegate = self
            }
            
            return cell
        } else if thisSection.type == .map {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as! ActivityMapCollectionViewCell
            
            
            return cell
        } else if thisSection.type == .inclusions {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inclusionsCell", for: indexPath) as! InclusionsCollectionViewCell
            
            if let inclusions = activityManager?.getActivityDetails()?.activityInclusion {
                cell.inclusionLabel.text = "• " + inclusions[indexPath.row].inclusionName
            }
            
            
            return cell
        } else if thisSection.type == .termsAndConditions {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as! TermsCollectionViewCell
            
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "activityHeader", for: indexPath) as! ActivityHeaderView
            
            headerView.headerLabel.text = "Inclusions"

//            guard let thisSection = activityManager?.getSections()?[indexPath.section] else { return headerView }


            return headerView
            
            
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


//MARK: ReadMoreDelegate
extension ActivityDetailsViewController: ReadMoreDelegate {
    func showReadMore(for type: ReadMoreTypes, content: String?) {
        print("\n\n delegate: \(content)")
        performSegue(withIdentifier: "toReadMore", sender: content)
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
                
            } else if thisSection.type == .activityDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .description {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 30
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .map {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .inclusions {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .termsAndConditions {
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



