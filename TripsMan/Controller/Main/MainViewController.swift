//
//  MainViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit
import FirebaseDynamicLinks

class MainViewController: UIViewController {

    @IBOutlet weak var homeCollection: UICollectionView! {
        didSet {
            homeCollection.collectionViewLayout = createLayout()
            homeCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            homeCollection.dataSource = self
            homeCollection.delegate = self
        }
    }
    
    enum SectionTypes {
        case banner
        case tiles
    }
    
    struct HomeSection {
        var type: SectionTypes
        var count: Int
    }
    
    struct HomeTiles {
        var title: String
        var image: String
        var backgroundImage: String
        var segue: String? = nil
    }
    
    var sections: [HomeSection]? = nil
    var homeTiles = [HomeTiles]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addMenuButton(with: ".")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeTiles = [HomeTiles(title: "Hotels", image: "home-cat-icon-Hotels", backgroundImage: "home-cat-Hotels", segue: "toHotelList"),
                     HomeTiles(title: "Holiday Packages", image: "home-cat-icon-Holiday", backgroundImage: "home-cat-Holiday"),
                     HomeTiles(title: "Activities", image: "home-cat-icon-Activities", backgroundImage: "home-cat-Activities"),
                     HomeTiles(title: "Meetups", image: "home-cat-icon-Meetups", backgroundImage: "home-cat-Meetups")]
        sections = [HomeSection(type: .banner, count: 3),
                    HomeSection(type: .tiles, count: homeTiles.count)]
        
        
        testURL()
    }
    
    func testURL() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tripsmanhexeam.page.link"
        components.path = "/resetPassword"
        
        let tokenQueryItem = URLQueryItem(name: "token", value: "abakjfbak282892jakwdn82nduka")
        components.queryItems = [tokenQueryItem]
        
        guard let linkParameter = components.url else { return }
        print("I am sharing \(linkParameter.absoluteString)")
        
        //DynamicLink
        guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://tripsmanhexeam.page.link") else {
            print("Couldn't create FDL components")
            return
        }
        
        if let myBundleID = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleID)
        }
        shareLink.iOSParameters?.appStoreID = "6444074382"
        
        shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.hexeam.tripsman")
        
        guard let longURL = shareLink.url else { return }
        print("The long dynamic link is \(longURL.absoluteURL)")
        
        shareLink.shorten { (url, warning, error) in
            if let error = error {
                print("FDL error \(error)")
                return
            }
            if let warning = warning {
                print("FDL warning \(warning)")
            }
            guard let url = url else { return }
            print("Shorten url is \(url.absoluteString)")
        }
        
    }
    
    
    @IBAction func buttonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .banner {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath) as! HomeBannerCollectionViewCell
            
            
            return cell
        } else if thisSection.type == .tiles {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! HomeTileCollectionViewCell
            
            cell.titleLabel.text = homeTiles[indexPath.row].title
            cell.titleIcon.image = UIImage(named: homeTiles[indexPath.row].image)
            cell.backgroundImage.image = UIImage(named: homeTiles[indexPath.row].backgroundImage)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .tiles {
            guard let segue = homeTiles[indexPath.row].segue else { return }
            performSegue(withIdentifier: segue, sender: nil)
        }
    }
}


extension MainViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
//            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            
            guard let thisSection = self.sections?[sectionIndex] else { return nil }
            
            let section: NSCollectionLayoutSection
            
            
            if thisSection.type == .banner {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .fractionalWidth(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section
                
                
            } else if thisSection.type == .tiles {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                                  heightDimension: .fractionalWidth(0.45)),
                                                               subitem: item,
                                                               count: 2)
                group.interItemSpacing = .fixed(10)
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 8, bottom: 20, trailing: 8)
                return section
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
