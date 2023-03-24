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
    
    var delegate: CountryPickerDelegate?
    
    let parser = Parser()

    override func viewDidLoad() {
        super.viewDidLoad()

        getCountries()
    }

}

//MARK: - APICalls
extension CountryListingViewController {
    func getCountries() {
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
}

extension CountryListingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        countryCollectionView.reloadData()
    }
}

extension CountryListingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return countryManager?.getSections(searchBar.text ?? "")?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = countryManager?.getSections(searchBar.text ?? "")?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        delegate?.countryDidSelected((countryManager?.getCountries(searchBar.text ?? "")![indexPath.row])!)
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
}

