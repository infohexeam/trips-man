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
        case complete
        case summary
        case review
    }
    
    struct TripDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [TripDetailsSection]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "My Trips")
        tripDetailsCollection.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [TripDetailsSection(type: .complete, count: 1),
                    TripDetailsSection(type: .summary, count: 1),
                    TripDetailsSection(type: .review, count: 1)]
        
        hideKeyboardOnTap()

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
        
        if thisSection.type == .complete {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripDetailsCell", for: indexPath)
            
            
            
            return cell
        } else if thisSection.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath)
            
            
            return cell
        } else if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath)
            
            
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
            
            
            if thisSection.type == .complete {
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
                
                
            } else  if thisSection.type == .summary {
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
                
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}



