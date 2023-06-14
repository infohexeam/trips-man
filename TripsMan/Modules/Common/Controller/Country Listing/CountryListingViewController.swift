//
//  CountryListingViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 21/03/23.
//

import UIKit

class CountryListingViewController: UIViewController {
    
    @IBOutlet weak var countryCollectionView: UICollectionView! {
        didSet {
            countryCollectionView.collectionViewLayout = createLayout()
            countryCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            countryCollectionView.dataSource = self
            countryCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var countryManager: CountryManager?
    var countries: [Country]? {
        didSet {
            if let countries = countries {
                countryManager = CountryManager(countries: countries)
                countryCollectionView.reloadData()
            }
        }
    }
    
    var cities: [City]? {
        didSet {
            if let cities = cities {
                countryManager = CountryManager(cities: cities)
                countryCollectionView.reloadData()
            }
        }
    }
    
    var delegate: CountryPickerDelegate?
    var listType: ListType?
    var isCity = false
    var countryId: Int?
    
    let parser = Parser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if listType == .packages {
            getPackageCountries()
        } else if listType == .activities {
            getActivityCountries()
        } else if listType == .meetups {
            if isCity {
                getMeetupCities()
            } else {
                getMeetupCountries()
            }
        }
    }

}

//MARK: - APICalls
extension CountryListingViewController {
    func getPackageCountries() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerHoliday/GetCustomerHolidayCountryList", http: .get, parameters: nil) { (result: CountryData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.countries = result!.data
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    func getActivityCountries() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerActivity/GetCustomerActivityCountryList", http: .get, parameters: nil) { (result: CountryData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.countries = result!.data
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    func getMeetupCountries() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerMeetup/GetCustomerMeetupCountryList", http: .get, parameters: nil) { (result: CountryData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.countries = result!.data
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                    
            }
        }
    }
    
    func getMeetupCities() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerMeetup/GetCustomerMeetupCityList?CountryId=\(countryId ?? 0)", http: .get, parameters: nil) { (result: CityData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.cities = result!.data
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

extension CountryListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        countryCollectionView.reloadData()
    }
}

extension CountryListingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isCity {
            return countryManager?.getCitySection(searchBar.text ?? "")?.count ?? 0
        }
        return countryManager?.getSections(searchBar.text ?? "")?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isCity {
            guard let thisSection = countryManager?.getCitySection(searchBar.text ?? "")?[section] else { return 0 }
            return thisSection.count
        }
        guard let thisSection = countryManager?.getSections(searchBar.text ?? "")?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isCity {
            guard let thisSection = countryManager?.getCitySection(searchBar.text ?? "")?[indexPath.section] else { return UICollectionViewCell() }
            
            if thisSection.type == .countryList {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "countryCell", for: indexPath) as! CountryCollectionViewCell
                
                if let cities = countryManager?.getCities(searchBar.text ?? "") {
                    cell.countryIcon.image = UIImage(systemName: "globe")
                    cell.countryName.text = cities[indexPath.row].cityName
                }
                
                return cell
            }  else {
                return UICollectionViewCell()
            }
        }
        
        guard let thisSection = countryManager?.getSections(searchBar.text ?? "")?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .countryList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "countryCell", for: indexPath) as! CountryCollectionViewCell
            
            if let countries = countryManager?.getCountries(searchBar.text ?? "") {
                cell.countryIcon.sd_setImage(with: URL(string: countries[indexPath.row].icon ?? ""), placeholderImage: UIImage(systemName: "globe"))
                cell.countryName.text = countries[indexPath.row].name
            }
            
            return cell
        }  else {
            return UICollectionViewCell()
        }
    }
}

extension CountryListingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCity {
            delegate?.cityDidSelected(countryManager?.getCities(searchBar.text ?? "")?[indexPath.row].cityName ?? "")
        } else {
            delegate?.countryDidSelected((countryManager?.getCountries(searchBar.text ?? "")![indexPath.row])!)
        }
        self.dismiss(animated: true)
    }
}


extension CountryListingViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.countryManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .countryList {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
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


protocol CountryPickerDelegate {
    func countryDidSelected(_ country: Country)
    func cityDidSelected(_ cityName: String)
}

