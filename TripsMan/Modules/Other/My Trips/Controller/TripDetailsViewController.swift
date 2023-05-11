//
//  TripDetailsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 16/12/22.
//

import UIKit

class TripDetailsViewController: UIViewController {
    
    @IBOutlet weak var tripDetailsCollection: UICollectionView! {
        didSet {
            tripDetailsCollection.collectionViewLayout = createLayout()
            tripDetailsCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tripDetailsCollection.dataSource = self
//            tripDetailsCollection.delegate = self
        }
    }
    
    enum SectionTypes {
        case tripDetails
        case priceDetails
        case review
        case action
    }
    
    struct TripDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [TripDetailsSection]? = nil
    var delegate: TripsRefreshDelegate?
    
    let parser = Parser()
    var tripDetails: TripDetails? {
        didSet {
            sections = [TripDetailsSection(type: .tripDetails, count: 1),
                        TripDetailsSection(type: .priceDetails, count: tripDetails!.amountDetails.count)]
            if tripDetails!.tripStatusValue == 1 {
                sections?.append(TripDetailsSection(type: .review, count: 1))
            }
            if tripDetails!.tripStatusValue == 0 {
                sections?.append(TripDetailsSection(type: .action, count: 1))
            }
            tripDetailsCollection.reloadData()
        }
    }
    var bookingId = 0
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "My Trips")
        getTripDetails()
        tripDetailsCollection.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardOnTap()
    }
    
    
    @IBAction func cancelBookingTapped() {
        cancelBooking()
    }
    
    @IBAction func editReviewTapped() {
        performSegue(withIdentifier: "toAddReview", sender: nil)
    }
    
    func getSection(_ type: SectionTypes) -> Int? {
        if sections != nil {
            for i in 0..<sections!.count {
                if sections![i].type == type {
                    return i
                }
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let vc = nav.topViewController as? AddReviewViewController {
                vc.reviewDelegate = self
                vc.tripDetails = tripDetails
            }
        }
    }
    
}

//MARK: - APICalls
extension TripDetailsViewController {
    func getTripDetails(_ isRefresh: Bool = false) {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/GetCustomerHotelBookingById?BookingId=\(bookingId)&Language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: TripDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.tripDetails = result!.data
                        if isRefresh {
                            self.delegate?.refreshTrips()
                        }
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    
    func cancelBooking() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/CancelCustomerHotelBooking?BookingId=\(bookingId)&Language=\(SessionManager.shared.getLanguage())", http: .post, parameters: nil) { (result: BasicResponse?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.getTripDetails(true)
                        self.view.makeToast(result!.message)
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

extension TripDetailsViewController: AddReviewDelegate {
    
    func refreshReview() {
        getTripDetails()
    }
    
    func addReviewClicked() {
        performSegue(withIdentifier: "toAddReview", sender: nil)
    }
    
}

extension TripDetailsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .tripDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripDetailsCell", for: indexPath) as! TripDetailsCollectionViewCell
            
            if let tripDetails = tripDetails {
                cell.tripStatus.text = tripDetails.tripStatus
                cell.bookingID.text = "BOOKING ID - \(tripDetails.bookingNo ?? "")"
                cell.tripMessage.text = tripDetails.tripMessage
                
                cell.hotelName.text = tripDetails.hotelName
                cell.hotelImage.sd_setImage(with: URL(string: tripDetails.imageURL ?? ""), placeholderImage: UIImage(named: "hotel-default-img"))
                cell.hotelAddress.text = tripDetails.hotelDetails.address
                
                cell.checkinDate.text = tripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy")
                cell.checkinTime.text = tripDetails.hotelDetails.checkInTime?.date("HH:mm a")?.stringValue(format: "HH:mm:ss")
                cell.checkoutDate.text = tripDetails.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy")
                cell.checkoutTime.text = tripDetails.hotelDetails.checkOutTime?.date("HH:mm:ss")?.stringValue(format: "HH:mm a")
                cell.countLabel.text = "\(tripDetails.roomCount) Room(s) for \(tripDetails.adultCount) Adult(s), \(tripDetails.childCount) Child(s)"
                cell.primaryGuest.text = "Primary Guest: \(tripDetails.primaryGuest)"
                cell.tripSpec.text = ""
                cell.roomType.text = tripDetails.roomDetails[0].roomType
                
            }
            
            
            return cell
        } else if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            
            if let amountDetails = tripDetails?.amountDetails[indexPath.row] {
                cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 12)
                
                cell.keyLabel.text = amountDetails.label
                cell.valueLabel.text = "\(SessionManager.shared.getCurrency()) \(amountDetails.amount)"
                
                if amountDetails.isTotalAmount == 1 {
                    cell.keyLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                    cell.valueLabel.font = UIFont(name: "Roboto-Bold", size: 15)
                }
            }
            return cell
        } else if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! AddReviewCollectionViewCell
            cell.delegate = self
            cell.ratedView.isHidden = true
            cell.addReviewButton.isHidden = false
            
            if let review = tripDetails?.review {
                cell.ratedView.isHidden = false
                cell.addReviewButton.isHidden = true
                
                cell.rating.rating = tripDetails?.rating ?? 1
                cell.reviewLabel.text = review
                cell.reviewTitleLabel.text = tripDetails?.reviewTitle
                cell.dateLabel.text = "Reviewed on " + (tripDetails?.reviewDate?.date("dd/MM/yyyy HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")
                
                if review == "" {
                    cell.reviewLabel.isHidden = true
                    cell.dateLabel.isHidden = true
                } else {
                    cell.reviewLabel.isHidden = false
                    cell.dateLabel.isHidden = false
                }
                
                if tripDetails?.reviewTitle != nil {
                    cell.reviewTitleLabel.isHidden = false
                } else {
                    cell.reviewTitleLabel.isHidden = true
                }
            }
                
            
            return cell
        } else if thisSection.type == .action {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actionCell", for: indexPath) as! TripDetailsActionCollectionViewCell
            
            
            return cell
        }
        
        
        
        return UICollectionViewCell()
        
    }
}

extension TripDetailsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .tripDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                return section
                
                
            } else  if thisSection.type == .priceDetails {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                return section
                
                
            }  else  if thisSection.type == .review {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                return section
                
                
            } else if thisSection.type == .action {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                return section
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}



