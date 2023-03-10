//
//  MyTripsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 14/12/22.
//

import UIKit

class MyTripsViewController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var myTripsCollection: UICollectionView! {
        didSet {
            myTripsCollection.collectionViewLayout = createLayout()
            myTripsCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            myTripsCollection.dataSource = self
            myTripsCollection.delegate = self
        }
    }
    
    enum SectionTypes {
        case myTrips
    }
    
    struct MyTripsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [MyTripsSection]? = nil
    
    var selectedIndex = 0 {
        didSet {
            if selectedIndex == 0 {
                tripsToShow = myTrips
            } else if selectedIndex == 1 {
                tripsToShow = myTrips.filter { $0.tripStatusValue == 0 }
            } else if selectedIndex == 2 {
                tripsToShow = myTrips.filter { $0.tripStatusValue == 1}
            } else if selectedIndex == 3 {
                tripsToShow = myTrips.filter { $0.tripStatusValue == 3}
            }
        }
    }
    
    let parser = Parser()
    var myTrips = [MyTrips]() {
        didSet {
            tripsToShow = myTrips
        }
    }
    
    var tripsToShow = [MyTrips]() {
        didSet {
            sections = [MyTripsSection(type: .myTrips, count: tripsToShow.count)]
            myTripsCollection.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addMenuButton(with: "My Trips")
        if SessionManager.shared.getLoginDetails() == nil {
            tabBarDelegate?.switchTab(0)
            tabBarDelegate?.presentVC("toLogin")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SessionManager.shared.getLoginDetails() != nil {
            getMyTrips()
        }
        
        segment.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)
        
        print("-----trips- viewDidLoad")

    }
    
    //IBACtions
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripDetailsViewController {
            if let index = sender as? Int {
                vc.bookingId = tripsToShow[index].bookingID
                vc.delegate = self
            }
        }
    }

}

//MARK: - APICalls

extension MyTripsViewController {
    func getMyTrips() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/GetCustomerHotelBookingList", http: .get, parameters: nil) { (result: MyTripsData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.myTrips = result!.data
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

extension MyTripsViewController: TripsRefreshDelegate {
    func refreshTrips() {
        getMyTrips()
    }
}


extension MyTripsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .myTrips {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myTripsCell", for: indexPath) as! TripListCell
            
            let data = tripsToShow[indexPath.row]
            
            cell.tripImage.sd_setImage(with: URL(string: data.imageURL ?? ""), placeholderImage: UIImage(named: "hotel-default-img"))
            let checkin = data.checkInDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
            let checkout = data.checkOutDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
            cell.statusLabel.text = "\(data.tripStatus!) | \(checkin ?? "") - \(checkout ?? "")"
            cell.hotelName.text = data.hotelName
            cell.bookedDate.text = data.bookedDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMM dd, yyyy")
            cell.primaryGuest.text = data.primaryGuest
            cell.roomCount.text = "\(data.roomCount) Room(s)"
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTripDetails", sender: indexPath.row)
    }
    
}

extension MyTripsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .myTrips {
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
                
                
            }  else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

protocol TripsRefreshDelegate {
    func refreshTrips()
}

