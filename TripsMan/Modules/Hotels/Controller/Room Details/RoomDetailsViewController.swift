//
//  RoomDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/05/23.
//

import UIKit
import Combine

class RoomDetailsViewController: UIViewController {
    
    @IBOutlet weak var roomCollectionView: UICollectionView! {
        didSet {
            roomCollectionView.collectionViewLayout = createLayout()
            roomCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            roomCollectionView.dataSource = self
        }
    }
    
    var roomManager: RoomDetailsManager?
    var hotelRoom: HotelRoom?
    var delegate: RoomCellDelegate?
    
    var index = 0
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let hotelRoom = hotelRoom {
            print(hotelRoom)
            roomManager = RoomDetailsManager(roomDetails: hotelRoom)
            roomCollectionView.reloadData()
        }
    }
    
    @IBAction func selectRoomTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        delegate?.selectTapped(index)
    }
}


//MARK: - UICollectionView
extension RoomDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return roomManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = roomManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = roomManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! HotelImageCollectionViewCell
            if let image = roomManager?.getRoomDetails()?.roomImages?[indexPath.row] {
                cell.hotelImage.sd_setImage(with: URL(string: image.roomImage ?? ""), placeholderImage: UIImage(systemName: K.hotelPlaceHolderImage))

            }
            
            return cell
        } else if thisSection.type == .roomDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomDetailsCell", for: indexPath) as! RoomDetailsCollectionViewCell
            
            if let details = roomManager?.getRoomDetails() {
                cell.roomName.text = details.roomType
                cell.roomDescription.setAttributedHtmlText(details.roomDescription)
            }
            
            return cell
        } else if thisSection.type == .facilities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "facilitiesCell", for: indexPath) as! HotelFacilitiesCollectionViewCell
            if let facilities = roomManager?.getRoomDetails()?.roomFacilities {
                cell.facilityIcon.sd_setImage(with: URL(string: facilities[indexPath.row].roomFacilityICon))
                cell.facilityLabel.text = facilities[indexPath.row].roomFacilityName
            }
            
            return cell
        }  else if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomPricecell", for: indexPath) as! RoomPriceDetailsCollectionViewCell
            if let details = roomManager?.getRoomDetails() {
                cell.pricePerNight.text = "\(SessionManager.shared.getCurrency()) \(details.actualPrice)"
                cell.taxAndFees.text = "\(SessionManager.shared.getCurrency()) \(details.serviceChargeValue)"
                
                let totalAmount = details.actualPrice + details.serviceChargeValue
                cell.totalAmount.text = "\(SessionManager.shared.getCurrency()) \(totalAmount)"
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "hotelDetailsFooter", for: indexPath) as! HotelDetailsFooterView
            
            footerView.configure(with: roomManager?.getRoomDetails()?.roomImages?.count ?? 0)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
        default:
            return UICollectionReusableView()
        }
    }
}



//MARK: - Layout
extension RoomDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.roomManager?.getSections()?[sectionIndex] else { return nil }
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
                
            } else if thisSection.type == .roomDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .facilities {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                      heightDimension: .absolute(20))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                
            } else if thisSection.type == .priceDetails {
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
