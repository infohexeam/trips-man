//
//  HotelDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 26/09/22.
//

import UIKit
import CoreLocation
import MapKit

class HotelDetailsViewController: UIViewController {
    
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageContainer: UIView!
    
    var checkin = ""
    var checkout = ""
    
    var facilityCount = 5
    
    var fontSize: CGFloat? = nil
    
    var detailsFullText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi aliquip commodo Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi aliquip commodo"
    var linesToShow = 3
    
    var termsLinesToShow = 3
    
    @IBOutlet weak var hotelDetailsCollectionView: UICollectionView! {
        didSet {
            hotelDetailsCollectionView.collectionViewLayout = createLayout()
            hotelDetailsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            hotelDetailsCollectionView.dataSource = self
            hotelDetailsCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var imagesCollectionView: UICollectionView! {
        didSet {
            imagesCollectionView.collectionViewLayout = createImageLayout()
            imagesCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imagesCollectionView.dataSource = self
            imagesCollectionView.delegate = self
        }
    }
    
    enum SectionTypes {
        case hotelImage
        case hotelDetails
        case hotelAddrress
        case facilities
        case seperator
        case roomFilter
        case rooms
        case rules
        case terms
        case rating
        case review
        case roomImage
    }
    
    struct DetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [DetailsSection]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Hotel Details")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [DetailsSection(type: .hotelImage, count: 3),
                    DetailsSection(type: .hotelDetails, count: 1),
                    DetailsSection(type: .hotelAddrress, count: 1),
                    DetailsSection(type: .facilities, count: 7),
                    DetailsSection(type: .seperator, count: 1),
                    DetailsSection(type: .roomFilter, count: 1),
                    DetailsSection(type: .rooms, count: 3),
                    DetailsSection(type: .rules, count: 3),
                    DetailsSection(type: .terms, count: 1),
                    DetailsSection(type: .rating, count: 1),
                    DetailsSection(type: .review, count: 3)]
        
        pickerContainer.isHidden = true
        imageContainer.isHidden = true

    }
    
    @IBAction func datePickerDoneTapped(_ sender: UIBarButtonItem) {
        if datePicker.tag == 1 {
            checkin = datePicker.date.stringValue(format: "dd-MM-yyyy")
        } else if datePicker.tag == 2 {
            checkout = datePicker.date.stringValue(format: "dd-MM-yyyy")
        }
        pickerContainer.isHidden = true
        
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 5)]) //roomfilter section
    }
    
    @IBAction func checkinTapped(_ sender: UIButton) {
        datePicker.tag = 1
        pickerContainer.isHidden = false
        
    }
    
    @IBAction func checkoutTapped(_ sender: UIButton) {
        datePicker.tag = 2
        pickerContainer.isHidden = false
        
    }
    
    @IBAction func hideImageTapped(_ sender: UIButton) {
        imageContainer.isHidden = true
    }

}

//MARK: - CollectionView
extension HotelDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == imagesCollectionView {
            return 1
        }
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imagesCollectionView {
            return 3
        }
        guard let thisSection = sections?[section] else { return 0 }
        
        if thisSection.type == .facilities {
            return facilityCount
        }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! ImagesCollectionViewCell
            
            let imageArray = ["hotel-details-room-deluxe", "hotel-details-banner-img1", "hotel-details-room-super-deluxe.jpg"]
            
            cell.roomImage.image = UIImage(named: imageArray[indexPath.row])
            
            return cell
        }
        
        guard let thisSection = sections?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .hotelImage {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! HotelImageCollectionViewCell
            
            
            return cell
            
        } else if thisSection.type == .hotelDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailsCell", for: indexPath) as! HotelDetailsCollectionViewCell
            
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.labelAction(_:)))
            cell.detailsLabel.addGestureRecognizer(tap)
            cell.detailsLabel.isUserInteractionEnabled = true
            tap.delegate = self
            cell.detailsLabel.text = self.detailsFullText
            cell.detailsLabel.numberOfLines = linesToShow

            if linesToShow != 0 {
                let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 11.0)
                let readmoreFontColor = UIColor(named: "buttonBackgroundColor")!
                DispatchQueue.main.async {
                    cell.detailsLabel.addTrailing(with: "... ", moreText: "Read more ", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    
                }
            }
            
            return cell
        } else if thisSection.type == .hotelAddrress {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addressCell", for: indexPath) as! HotelAddrressCollectionViewCell
            
            let hotelLocation = CLLocationCoordinate2D(latitude: 11.274522051763812, longitude: 75.7926178448641)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
               let region = MKCoordinateRegion(center: hotelLocation, span: span)
            cell.addressMap.setRegion(region, animated: true)

            let annotation = MKPointAnnotation()
                annotation.coordinate = hotelLocation
                annotation.title = "The Orion"
            cell.addressMap.addAnnotation(annotation)
            return cell
            
        } else if thisSection.type == .facilities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "facilitiesCell", for: indexPath) as! HotelFacilitiesCollectionViewCell
            
            cell.moreView.isHidden = true
            cell.facilityIcon.image = UIImage(systemName: "wifi")
            cell.facilityIcon.tintColor = .white
            cell.facilityLabel.text = "Free Internet"
            cell.facilityLabel.textColor = .white
            
            let allFacilitites = thisSection.count
            if allFacilitites > facilityCount {
                if indexPath.row == facilityCount - 1 {
                    cell.moreView.isHidden = false
                    cell.facilityIcon.image = UIImage(systemName: "plus")
                    cell.facilityIcon.tintColor = .tintColor
                    cell.facilityLabel.text = "More"
                    cell.facilityLabel.textColor = .tintColor
                }
            }

            return cell
        } else if thisSection.type == .seperator {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "separator", for: indexPath) as! SeperatorCell
            
            return cell
        } else if thisSection.type == .roomFilter {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomFilterCell", for: indexPath) as! RoomFilterCollectionViewCell
            
            cell.checkin = self.checkin
            cell.checkout = self.checkout
            cell.setupView()
            
            return cell
        } else if thisSection.type == .rooms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomsCell", for: indexPath) as! HotelRoomsCollectionViewCell
            
            cell.delegate = self
            if fontSize == nil {
                fontSize = cell.priceLabel.font.pointSize
            }
            cell.priceLabel.addPriceString("3999", "2999", fontSize: fontSize!)
            
            
            return cell
        } else if thisSection.type == .rules {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rulesCell", for: indexPath) as! PropertyRulesCollectionViewCell
            
            return cell
        } else if thisSection.type == .terms {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "termsCell", for: indexPath) as! TermsCollectionViewCell
            
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.termsLabelAction(_:)))
            cell.termsLabel.addGestureRecognizer(tap)
            cell.termsLabel.isUserInteractionEnabled = true
            tap.delegate = self
            cell.termsLabel.text = self.detailsFullText
            cell.termsLabel.numberOfLines = termsLinesToShow

            if termsLinesToShow != 0 {
                let readmoreFont = UIFont(name: "Helvetica-Oblique", size: 11.0)
                let readmoreFontColor = UIColor(named: "buttonBackgroundColor")!
                DispatchQueue.main.async {
                    cell.termsLabel.addTrailing(with: "... ", moreText: "Read more ", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    
                }
            }
            return cell
        } else if thisSection.type == .rating {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingCell", for: indexPath) as! RatingCollectionViewCell
            
            return cell
        } else if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! ReviewCollectionViewCell
            
            return cell
        } else {
            fatalError("Unknown section!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detailsHeader", for: indexPath) as! HotelDetailsHeaderView
            
            guard let thisSection = sections?[indexPath.section] else { return headerView }
            
            if thisSection.type == .hotelAddrress {
                headerView.titleLabel.text = "Address"
            } else if thisSection.type == .facilities {
                headerView.titleLabel.text = "Facilities"
            } else if thisSection.type == .rules {
                headerView.titleLabel.text = "Property Rules"
            }
            
            return headerView
            
        default:
            return UICollectionReusableView()
//            assert(false, "Invalid Element Type")
        }
    }
}

extension HotelDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .rooms {
            if SessionManager.shared.getLoginDetails() == nil {
                tabBarDelegate?.switchTab(0)
                tabBarDelegate?.presentVC("toLogin")
            } else {
                performSegue(withIdentifier: "toRoomSelect", sender: nil)
            }
        } else if thisSection.type == .facilities {
            let allFacilties = thisSection.count
            if allFacilties > facilityCount {
                facilityCount = allFacilties
                collectionView.reloadItems(at: [IndexPath(row: 0, section: 3)])
            }
        }
        
    }
}

extension HotelDetailsViewController: UIGestureRecognizerDelegate {
    @objc func labelAction(_ gesture: UITapGestureRecognizer) {
        if linesToShow == 0 {
            linesToShow = 3
        } else {
            linesToShow = 0
        }
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
    }
    
    @objc func termsLabelAction(_ gesture: UITapGestureRecognizer) {
        if termsLinesToShow == 0 {
            termsLinesToShow = 3
        } else {
            termsLinesToShow = 0
        }
        hotelDetailsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 8)])
    }
}

extension HotelDetailsViewController: DynamicCellHeightDelegate {
    func updateHeight() {
        hotelDetailsCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension HotelDetailsViewController: ViewImageDelegate {
    func imageTapped(_ tag: Int) {
        imageContainer.isHidden = false
    }
}

//Layout
extension HotelDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .hotelImage {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.6))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                
            } else if thisSection.type == .hotelDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .hotelAddrress {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(containerWidth > 500 ? 0.3 : 0.6))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]

                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .facilities {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                      heightDimension: .estimated(60))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .seperator {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
            } else if thisSection.type == .roomFilter {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(44))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .rooms {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerWidth > 500 ? 0.425 : 0.85),
                                                       heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .rules {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(20))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(20))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(25))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [sectionHeader]
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
            } else if thisSection.type == .terms {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .rating {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 0, trailing: 8)
                
            } else if thisSection.type == .review {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 20, trailing: 8)
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func createImageLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            
            let section: NSCollectionLayoutSection
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 10
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
