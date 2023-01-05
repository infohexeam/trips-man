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
        
        sections = [MyTripsSection(type: .myTrips, count: 2)]
        
        segment.addTarget(self, action: #selector(indexChanged(_:)), for: .valueChanged)

    }
    
    //IBACtions
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            selectedIndex = 0
        case 1:
            selectedIndex = 1
        case 2:
            selectedIndex = 2
        default:
            break
        }
        
    }

}


extension MyTripsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //For demo
        if selectedIndex == 0 {
            return 4
        } else {
            return 2
        }
        
//        guard let thisSection = self.sections?[section] else { return 0 }
//
//        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .myTrips {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myTripsCell", for: indexPath) as! TripListCell
            
            
            //For Demo
            if selectedIndex == 0 {
                if indexPath.row == 0 || indexPath.row == 1 {
                    cell.statusLabel.text = "Upcoming | 12 Jan - 13 Jan"
                } else {
                    cell.statusLabel.text = "Completed | 10 Dec - 12 Dec"
                }
            } else if selectedIndex == 1 {
                cell.statusLabel.text = "Upcoming | 12 Jan - 13 Jan"
            } else if selectedIndex == 2 {
                cell.statusLabel.text = "Completed | 10 Dec - 12 Dec"
            }
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension MyTripsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toTripDetails", sender: nil)
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

