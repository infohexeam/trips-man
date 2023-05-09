//
//  MeetupDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/05/23.
//

import UIKit
import Combine
import CoreLocation
import MapKit

class MeetupDetailsViewController: UIViewController {
    
    @IBOutlet weak var meetupCollectionView: UICollectionView! {
        didSet {
            meetupCollectionView.collectionViewLayout = createLayout()
            meetupCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            meetupCollectionView.dataSource = self
        }
    }
    
    var meetupManager: MeetupDetailsManager?
    var parser = Parser()
    var meetupID = 0
    var meetupFilters = MeetupFilters()
    
    var fontSize: CGFloat? = nil
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Meetup Details")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getmeetupDetails()

    }
    
    @IBAction func bookNowTapped(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? ReadMoreViewController {
                if let content = sender as? String {
                    vc.readMoreContent = content
                }
            }
            
//        } else  if let vc = segue.destination as? ActivityBookingViewController {
//            activityFilters.activityDetails = activityManager?.getActivityDetails()
//            vc.activityFilters = activityFilters
        }
    }
}


//MARK: - APICalls
extension MeetupDetailsViewController {
    func getmeetupDetails() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerMeetup/GetCustomerMeetupById?MeetupId=\(meetupID)&Currency=\(SessionManager.shared.getCurrency())&Language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: MeetupDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.meetupManager = MeetupDetailsManager(meetupDetails: result!.data)
                        self.meetupCollectionView.reloadData()
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
extension MeetupDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return meetupManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = meetupManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = meetupManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meetupImageCell", for: indexPath) as! MeetupImageCollectionViewCell
            if let image = meetupManager?.getMeetupDetails()?.meetupImages[indexPath.row] {
                cell.meetupImage.sd_setImage(with: URL(string: image.imageURL), placeholderImage: UIImage(systemName: K.meetupPlaceholderImage))

            }
            
            return cell
        } else if thisSection.type == .meetupDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "meetupDetailsCell", for: indexPath) as! MeetupDetailsCollectionViewCell
            
            if let details = meetupManager?.getMeetupDetails() {
                if fontSize == nil {
                    fontSize = cell.priceLabel.font.pointSize
                }
                
                cell.meetupName.text = details.meetupName
                cell.priceLabel.addPriceString(details.costPerPerson, details.offerAmount, fontSize: fontSize!)
                cell.taxLabel.text = "+ \(SessionManager.shared.getCurrency()) \(details.serviceCharge) taxes and fee per person"
                cell.detailsLabel.text = details.shortDescription
                cell.dateLabel.text = details.meetupDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMMM dd")
            }
            
            return cell
        } else if thisSection.type == .description {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "descriptionCell", for: indexPath) as! MeetupDescriptionCollectionViewCell
            
            if let description = meetupManager?.getDescription() {
                cell.descTitle.text = description[indexPath.row].title
                cell.descDetails.attributedText = description[indexPath.row].description.attributedHtmlString
                cell.delegate = self
            }
            
            return cell
        } else if thisSection.type == .map {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mapCell", for: indexPath) as! MeetupMapCollectionViewCell
            if let details = meetupManager?.getMeetupDetails() {
                let meetupLocation = CLLocationCoordinate2D(latitude: Double(details.latitude) ?? 0.0, longitude: Double(details.longitude) ?? 0.0)
                let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                let region = MKCoordinateRegion(center: meetupLocation, span: span)
                cell.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = meetupLocation
                annotation.title = details.meetupName
                cell.mapView.addAnnotation(annotation)
                
                cell.addressLabel.text = details.address
            }
            
            
            return cell
        } else if thisSection.type == .termsAndConditions {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as! TermsCollectionViewCell
            if let details = meetupManager?.getMeetupDetails() {
                cell.delegate = self
                cell.termsLabel.setAttributedHtmlText(details.termsAndConditions)
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "meetupFooter", for: indexPath) as! MeetupDetailsFooterView
            
            footerView.configure(with: meetupManager?.getMeetupDetails()?.meetupImages.count ?? 0)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
}


//MARK: ReadMoreDelegate
extension MeetupDetailsViewController: ReadMoreDelegate {
    func showReadMore(for type: ReadMoreTypes, content: String?) {
        print("\n\n delegate: \(content)")
        performSegue(withIdentifier: "toReadMore", sender: content)
    }
}


//MARK: - Layout
extension MeetupDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.meetupManager?.getSections()?[sectionIndex] else { return nil }
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
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [sectionFooter]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: -30, trailing: 8)
                
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }
                    
                    let page = round(offset.x / self.view.bounds.width)
                    
                    self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }
                
                return section
                
            } else if thisSection.type == .meetupDetails {
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

