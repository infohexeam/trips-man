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
    
    
    var delegate: TripsRefreshDelegate?
    
    var tripManager: TripDetailsManager?
    
    let parser = Parser()
    var tripDetails: HotelTripDetails? {
        didSet {
            tripManager = TripDetailsManager(hotelTripDetails: tripDetails)
            tripDetailsCollection.reloadData()
        }
    }
    
    var bookingId = 0
    var module: ListType?
    
    
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
    
    func getTripDetails() {
        if let module = module {
            switch module {
            case .hotel:
                getHotelBookingDetails()
            case .packages:
                getHolidayBookingDetails()
            case .activities:
                break
            case .meetups:
                break
            }
        }
    }
    
    
    @IBAction func cancelBookingTapped() {
        cancelBooking()
    }
    
    @IBAction func editReviewTapped() {
        performSegue(withIdentifier: "toAddReview", sender: nil)
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
    func getHotelBookingDetails(_ isRefresh: Bool = false) {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/GetCustomerHotelBookingById?BookingId=\(bookingId)&Language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: HotelTripDetailsData?, error) in
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
    
    func getHolidayBookingDetails(_ isRefresh: Bool = false) {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHoliday/GetCustomerHolidayBookingById?BookingId=\(bookingId)&Language=\(SessionManager.shared.getLanguage())", http: .get, parameters: nil) { (result: HolidayTripDetailsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.tripManager = TripDetailsManager(holidayTripDetails: result!.data)
                        self.tripDetailsCollection.reloadData()
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
//                        self.getTripDetails(true)
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
        return tripManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = tripManager?.getSections()?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.tripManager?.getSections()?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .tripDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripDetailsCell", for: indexPath) as! TripDetailsCollectionViewCell
            
            
            if let topBox = tripManager?.getDetailsData()?.topBox {
                cell.tripStatus.text = topBox.tripStatus
                cell.bookingID.text = topBox.bookingNo
                cell.bookedDate.text = topBox.bookedDate
                cell.tripMessage.text = topBox.tripMessage
            }
            
            if let secondBox = tripManager?.getDetailsData()?.secondBox {
                cell.name.text = secondBox.name
                cell.image.sd_setImage(with: URL(string: secondBox.image), placeholderImage: UIImage(named: K.hotelPlaceHolderImage))
                cell.address.text = secondBox.address
            }
            
            if let thirdBox = tripManager?.getDetailsData()?.thirdBox {
                cell.fromDateLabel.text = thirdBox.fromDate.label
                cell.fromDateText.text = thirdBox.fromDate.date
                cell.fromDateTime.text = thirdBox.fromDate.time
                
                cell.toDateView.isHidden = true
                if let toDate = thirdBox.toDate {
                    cell.toDateView.isHidden = false
                    cell.toDateLabel.text = toDate.label
                    cell.toDateText.text = toDate.date
                    cell.toDateTime.text = toDate.time
                }
                
                cell.roomAndGuestLabel.isHidden = true
                if let roomAndGuest = thirdBox.roomAndGuestCount {
                    cell.roomAndGuestLabel.isHidden = false
                    cell.roomAndGuestLabel.text = roomAndGuest
                }
                cell.roomTypeLabel.isHidden = true
                if let roomType = thirdBox.roomType {
                    cell.roomTypeLabel.isHidden = false
                    cell.roomTypeLabel.text = roomType
                }
                
                cell.primaryGuestLabel.text = thirdBox.primaryGuest.label
                cell.primaryGuestName.text = thirdBox.primaryGuest.nameText
                cell.primaryGuestContact.text = thirdBox.primaryGuest.contact
                
                cell.otherGuestView.isHidden = true
                if let otherGuest = thirdBox.otherGuests {
                    cell.otherGuestView.isHidden = false
                    cell.otherGuestLabel.text = otherGuest.label
                    cell.othterGuestText.text = otherGuest.text
                }
                
                
                cell.daysLabel.text = thirdBox.duration
            }
            
            return cell
        } else if thisSection.type == .priceDetails {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "priceDetailsCell", for: indexPath) as! PriceDetailsCollectionViewCell
            
            if let amountDetails = tripManager?.getAmountDetails()?[indexPath.row] {
                
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
                cell.dateLabel.text = "Reviewed on " + (tripDetails?.reviewDate?.date("MM/dd/yyyy HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")
                
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
            
            guard let thisSection = self.tripManager?.getSections()?[sectionIndex] else { return nil }
            
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



