//
//  NotificationViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 12/12/22.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var notificationCollection: UICollectionView! {
        didSet {
            notificationCollection.collectionViewLayout = createLayout()
            notificationCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            notificationCollection.dataSource = self
//            notificationCollection.delegate = self
        }
    }
    
    enum SectionTypes {
        case notifications
    }
    
    struct NotifSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [NotifSection]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Notifications")
        self.title = "Notifications"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sections = [NotifSection(type: .notifications, count: 3)]
        
    }

}

extension NotificationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .notifications {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notificationCell", for: indexPath)
            
            
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension NotificationViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .notifications {
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
