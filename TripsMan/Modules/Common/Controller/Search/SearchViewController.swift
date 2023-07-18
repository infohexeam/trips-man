//
//  SearchViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 17/02/23.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchCollectionView: UICollectionView! {
        didSet {
            searchCollectionView.collectionViewLayout = createLayout()
            searchCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            searchCollectionView.dataSource = self
            searchCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    enum SectionTypes {
        case searchList
    }
    
    struct SearchSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [SearchSection]? = nil
    let parser = Parser()
    var search: Search? {
        didSet {
            searchManager = SearchManager(search: search)
            sections = [SearchSection(type: .searchList, count: searchManager?.getSearchResults()?.count ?? 0)]
            searchCollectionView.reloadData()
        }
    }
    
    var module = ""
    var searchManager: SearchManager?
    
    var delegate: SearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if module == "HTL" {
            self.searchBar.placeholder = "Search hotels.."
        } else if module == "HDY" {
            self.searchBar.placeholder = "Search packages.."
        } else if module == "ACT" {
            self.searchBar.placeholder = "Search activities.."
        } else if module == "MTP" {
            self.searchBar.placeholder = "Search meetup.."
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.getSearchList(_:)), object: searchBar)
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            perform(#selector(self.getSearchList(_:)), with: searchBar, afterDelay: 0.75)
        } else {
            searchManager = SearchManager(search: nil)
            sections = [SearchSection(type: .searchList, count: 0)]
            searchCollectionView.reloadData()
        }
    }
}

//MARK: - ApiCalls
extension SearchViewController {
    @objc func getSearchList(_ searchBar: UISearchBar) {
        showIndicator()
        
        let params: [String: Any] = ["Search": searchBar.text!,
                                     "Module": module,
                                     "country": SessionManager.shared.getCountry().countryCode,
                                     "currency": SessionManager.shared.getCurrency(),
                                     "language": SessionManager.shared.getLanguage().code]
        
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHotelSearch", http: .post, parameters: params) { (result: SearchData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.search = result!.data
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


extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchListCell
        if let searchResult = searchManager?.getSearchResults()?[indexPath.row] {
            cell.mainLabel.text = searchResult.name
            cell.subLabel.text = searchResult.type
        }
        return cell
    }
    
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let search = search {
            delegate?.searchItemDidPressed(search, index: indexPath.row)
            self.dismiss(animated: true)
        }
    }
}


extension SearchViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
//            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .searchList {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
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


protocol SearchDelegate {
    func searchItemDidPressed(_ item: Search, index: Int)
}
