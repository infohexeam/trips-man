//
//  MyTripsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 14/12/22.
//

import UIKit

class MyTripsViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var filterByButton: UIButton!
    
    @IBOutlet weak var myTripsCollection: UICollectionView! {
        didSet {
            myTripsCollection.collectionViewLayout = createLayout()
            myTripsCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            myTripsCollection.dataSource = self
            myTripsCollection.delegate = self
        }
    }
    
    var selectedIndex = 0 {
        didSet {
            //            if selectedIndex == 0 {
            //                tripsToShow = myTrips
            //            } else if selectedIndex == 1 {
            //                tripsToShow = myTrips.filter { $0.tripStatusValue == 0 }
            //            } else if selectedIndex == 2 {
            //                tripsToShow = myTrips.filter { $0.tripStatusValue == 1}
            //            } else if selectedIndex == 3 {
            //                tripsToShow = myTrips.filter { $0.tripStatusValue == 3}
            //            }
        }
    }
    
    var tripFilters = TripsFilters()
    var sorts = [Sortby]()
    var filters = [String]()
    
    var tripsManager: TripListManager?
    
    let parser = Parser()
    var myTrips = [MyTrips]() {
        didSet {
            tripsManager = TripListManager(myTrips: myTrips)
            myTripsCollection.reloadData()
        }
    }
    
    //    var tripsToShow = [MyTrips]() {
    //        didSet {
    //            sections = [MyTripsSection(type: .myTrips, count: tripsToShow.count)]
    //            myTripsCollection.reloadData()
    //        }
    //    }
    
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
        
        hideKeyboardOnTap()
        
        assignValues()
        setupMenus()
    }
    
    func assignValues() {
        sorts = [Sortby(name: "Latest first", id: 0),
                 Sortby(name: "Oldest first", id: 1)]
        
        filters = ["Hotel", "Holiday Package", "Activities", "Meetups"]
    }
    
    func setupMenus() {
        
        let sorts = sorts.map { UIAction(title: "\($0.name)", handler: sortHandler) }
        sortByButton.menu = UIMenu(title: "", children: sorts)
        sortByButton.showsMenuAsPrimaryAction = true
        
        let filters = filters.map { UIAction(title: "\($0)", handler: filterHandler) }
        filterByButton.menu = UIMenu(title: "", children: filters)
        filterByButton.showsMenuAsPrimaryAction = true
    }
    
    func sortHandler(action: UIAction) {
        
        let sortBy = sorts.filter { $0.name == action.title }.last
        if sortBy?.id == 0 {
            tripFilters.sortBy = Sortby(name: "ASCDATE", id: 0)
        } else if sortBy?.id == 1 {
            tripFilters.sortBy = Sortby(name: "DESCDATE", id: 1)
        }
        
        getMyTrips()
    }
    
    func filterHandler(action: UIAction) {
        
        let filter = filters.filter { $0 == action.title }.last
        if filter == "Hotel" {
            tripFilters.moduleCode = "HTL"
        } else if filter == "Holiday Package" {
            tripFilters.moduleCode = "HDY"
        } else if filter == "Activities" {
            tripFilters.moduleCode = "ACT"
        } else if filter == "Meetups" {
            tripFilters.moduleCode = "MTP"
        }
        
        getMyTrips()
    }
    
    //IBACtions
    @objc func indexChanged(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TripDetailsViewController {
            if let index = sender as? Int {
                vc.bookingId = tripsManager?.getTripsToShow()?[index].bookingID ?? 0
                vc.delegate = self
            }
        }
    }
    
}

extension MyTripsViewController {
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        tripFilters.searchText = textField.text
        getMyTrips()
        return true
    }
    
}

//MARK: - APICalls

extension MyTripsViewController {
    func getMyTrips() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotelBooking/GetCustomerBookingListAll?language=\(SessionManager.shared.getLanguage())&module_code=\(tripFilters.moduleCode ?? "")&search_text=\(tripFilters.searchText ?? "")&booking_status=\(tripFilters.bookingStatus?.status ?? "")&sortby=\(tripFilters.sortBy?.name ?? "")", http: .get, parameters: nil) { (result: MyTripsData?, error) in
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripsManager?.getTripsToShow()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myTripsCell", for: indexPath) as! TripListCell
        
        if let trip = tripsManager?.getTripsToShow()?[indexPath.row] {
            cell.tripImage.sd_setImage(with: URL(string: trip.imageUrl), placeholderImage: UIImage(named: trip.defaultImage))
            
            cell.topLabel.text = trip.topLabel
            cell.nameLabel.text = trip.name
            cell.subLabel.text = trip.subLabel
            cell.bottomIcon1.image = UIImage(systemName: trip.bottomLabels[0].icon)
            cell.bottomLabel1.text = trip.bottomLabels[0].text
            cell.bottomIcon2.image = UIImage(systemName: trip.bottomLabels[1].icon)
            cell.bottomLabel2.text = trip.bottomLabels[1].text
        }
        
        return cell
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
            
            let section: NSCollectionLayoutSection
            
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
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

protocol TripsRefreshDelegate {
    func refreshTrips()
}

