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
    
    let parser = Parser()
    
    var index = 0
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Room Details")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if hotelRoom != nil {
           getRoomDetails()
        }
    }
    
    @IBAction func selectRoomTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
        delegate?.selectTapped(index)
    }
}

//MARK: - ApiCalls
extension RoomDetailsViewController {
    func getRoomDetails() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetRoomList?hotelId=\(hotelRoom!.hotelID)&roomId=\(hotelRoom!.roomID)&currency=\(SessionManager.shared.getCurrency())&language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: RoomDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.roomManager = RoomDetailsManager(roomDetails: result!.data[0])
                        self.roomCollectionView.reloadData()
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
            if let image = roomManager?.getRoomDetails()?.roomImage[indexPath.row] {
                cell.hotelImage.sd_setImage(with: URL(string: image.roomImage ?? ""), placeholderImage: UIImage(systemName: K.hotelPlaceHolderImage))

            }
            
            return cell
        } else if thisSection.type == .roomDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomDetailsCell", for: indexPath) as! RoomDetailsCollectionViewCell
            
            if let details = roomManager?.getRoomDetails() {
                cell.roomName.text = details.hotelName + " | " + details.roomType
                cell.roomDescription.setAttributedHtmlText(details.roomDescription)
            }
            
            return cell
        } else if thisSection.type == .roomAmenities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amenititesCell", for: indexPath) as! RoomAmenitiesCollectionViewCell
            if let facilities = roomManager?.getRoomDetails()?.roomFacilities {
                cell.amenityIcon.sd_setImage(with: URL(string: facilities[indexPath.row].roomFacilityICon ?? ""), placeholderImage: UIImage(systemName: "square.righthalf.fill"))
                cell.amenityName.text = facilities[indexPath.row].roomFacilityName
            }
            
            return cell
        }   else if thisSection.type == .popularAmenities {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amenititesCell", for: indexPath) as! RoomAmenitiesCollectionViewCell
            if let amenities = roomManager?.getRoomDetails()?.popularAmenities {
                cell.amenityIcon.sd_setImage(with: URL(string: amenities[indexPath.row].roomPopularAmenityICon ?? ""), placeholderImage: UIImage(systemName: "square.righthalf.fill"))
                cell.amenityName.text = amenities[indexPath.row].roomPopularAmenityName
            }
            
            return cell
        } else if thisSection.type == .houseRules {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rulesCell", for: indexPath) as! HouseRulesCollectionViewCell
            
            if let rules = roomManager?.getRoomDetails()?.roomHouseRules {
                cell.rulesLabel.text = "• " + rules[indexPath.row].houseRulesName
            }
            
            return cell
        }  else if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "roomPricecell", for: indexPath) as! RoomPriceDetailsCollectionViewCell
            if let details = roomManager?.getRoomDetails() {
                var totalAmount: Double = 0
                if details.offerPrice > 0 {
                    cell.pricePerNight.text = "\(SessionManager.shared.getCurrency()) \(details.offerPrice)"
                    totalAmount = details.offerPrice + details.serviceChargeValue
                } else {
                    cell.pricePerNight.text = "\(SessionManager.shared.getCurrency()) \(details.roomPrice)"
                    totalAmount = details.roomPrice + details.serviceChargeValue
                }
                cell.taxAndFees.text = "\(SessionManager.shared.getCurrency()) \(details.serviceChargeValue)"
                
                cell.totalAmount.text = "\(SessionManager.shared.getCurrency()) \(totalAmount)"
            }
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "detailsHeader", for: indexPath) as! HotelDetailsHeaderView
            
            guard let thisSection = roomManager?.getSections()?[indexPath.section] else { return headerView }
            
            if thisSection.type == .roomAmenities {
                headerView.titleLabel.text = "Room Amenities"
            } else if thisSection.type == .popularAmenities {
                headerView.titleLabel.text = "Popular Amenities"
            } else if thisSection.type == .houseRules {
                headerView.titleLabel.text = "House Rules"
            }
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "hotelDetailsFooter", for: indexPath) as! HotelDetailsFooterView
            
            footerView.configure(with: roomManager?.getRoomDetails()?.roomImage.count ?? 0)
            
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
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionFooter]
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: -30, trailing: 0)
                
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
                
            } else if thisSection.type == .roomAmenities || thisSection.type == .popularAmenities {
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50),
                                                      heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(60))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [sectionHeader]
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 20, trailing: 8)
            } else if thisSection.type == .houseRules {
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
