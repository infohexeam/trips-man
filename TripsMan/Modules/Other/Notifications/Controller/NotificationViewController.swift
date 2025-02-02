//
//  NotificationViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 12/12/22.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var notificationsLabel: UILabel!
    
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
    
    let parser = Parser()
    var notifications = [Notifications]() {
        didSet {
            if notifications.count > 0 {
                sections = [NotifSection(type: .notifications, count: notifications.count)]
                notificationCollection.reloadData()

            } else {
                notificationsLabel.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addBackButton(with: "Notifications".localized())
        self.title = "Notifications".localized()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sections = [NotifSection]()
        getNotifications()
        notificationsLabel.isHidden = true
    }

}

//MARK: - APICalls
extension NotificationViewController {
    func getNotifications() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerHotel/GetNotifationList?Language=\(SessionManager.shared.getLanguage().code)", http: .get, parameters: nil) { (result: NotificationData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.notifications = result!.data
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast(K.apiErrorMessage)
                }
                    
            }
        }
    }
}

//MARK: - UICollectionView
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "notificationCell", for: indexPath) as! NotificationsCollectionViewCell
            
            let data = notifications[indexPath.row]
            cell.dateLabel.text = data.notificationDate.date("MM/dd/yyyy hh:mm:ss")?.stringValue(format: "MMM dd, yyyy")
            cell.notificationTitle.text = data.title
            cell.notificationText.text = data.notificationText
            
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension NotificationViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
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
