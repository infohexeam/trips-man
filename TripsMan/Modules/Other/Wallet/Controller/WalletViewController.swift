//
//  WalletViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 13/12/22.
//

import UIKit

class WalletViewController: UIViewController {
    
    @IBOutlet weak var walletCollection: UICollectionView! {
        didSet {
            walletCollection.collectionViewLayout = createLayout()
            walletCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            walletCollection.dataSource = self
        }
    }
    
    
    enum SectionTypes {
        case summary
        case listTitle
        case list
    }
    
    struct WalletSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [WalletSection]? = nil
    
    let parser = Parser()
    var wallet: Wallet? {
        didSet {
            sections = [WalletSection(type: .summary, count: 1),
                        WalletSection(type: .listTitle, count: 1),
                        WalletSection(type: .list, count: wallet!.detail.count)]
            
            walletCollection.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addMenuButton(with: "My Wallet".localized())
        if SessionManager.shared.getLoginDetails() == nil {
            tabBarDelegate?.switchTab(0)
            tabBarDelegate?.presentVC("toLogin")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [WalletSection(type: .summary, count: 1)]
        getWallet()
        
    }
    
}

//MARK: - APICalls
extension WalletViewController {
    func getWallet() {
        showIndicator()
        parser.sendRequestLoggedIn(url: "api/CustomerCoupon/GetCustomerWalletList?Language=\(SessionManager.shared.getLanguage().code)&Currency=\(SessionManager.shared.getCurrency())&Country=\(SessionManager.shared.getCountry().countryCode)", http: .get, parameters: nil) { (result: WalletData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.wallet = result!.data
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

extension WalletViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .summary {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summaryCell", for: indexPath) as! WalletSummaryCell
            
            if let wallet = wallet {
                cell.pointsLabel.text = "\(wallet.totalPoints)"
            }
            
            return cell
        } else if thisSection.type == .listTitle {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listTitleCell", for: indexPath)
            
            
            
            return cell
        } else if thisSection.type == .list {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! WalletListCell
            
            if let walletList = wallet?.detail[indexPath.row] {
                cell.dateLabel.text = walletList.date.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                cell.descLabel.text = walletList.description
                cell.pointLabel.text = "\(walletList.points)"
                if walletList.points < 0 {
                    cell.pointLabel.textColor = UIColor(named: "debitLabelColor")
                } else {
                    cell.pointLabel.textColor = UIColor(named: "creditLabelColor")
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension WalletViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .summary {
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
                
                
            } else if thisSection.type == .listTitle {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8)
                return section
                
            } else if thisSection.type == .list {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(10))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 20, trailing: 8)
                return section
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
