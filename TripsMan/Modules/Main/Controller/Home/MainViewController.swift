//
//  MainViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import UIKit
import FirebaseDynamicLinks
import Combine
import SDWebImage

class MainViewController: UIViewController {
    
    var refreshControl = UIRefreshControl()

    @IBOutlet weak var homeCollection: UICollectionView! {
        didSet {
            homeCollection.collectionViewLayout = createLayout()
            homeCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            homeCollection.dataSource = self
            homeCollection.delegate = self
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
            homeCollection.refreshControl = refreshControl
            
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
        var listType: ListType
    }
    
    var sections: [HomeSection]? = nil
    var homeTiles = [HomeTiles]()
    
    var currentPage = 0
    
    let parser = Parser()
    var banners = [Banners]() {
        didSet {
//            if sections?.count == 1 {
//                sections?.insert(HomeSection(type: .banner, count: banners.count), at: 0)
//            }
            homeCollection.reloadSections(IndexSet(integer: 0))
        }
    }
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addMenuButton(with: " ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        homeTiles = [HomeTiles(title: "Hotels", image: "home-cat-icon-Hotels", backgroundImage: "home-cat-Hotels", segue: "toHotelList", listType: .hotel),
                     HomeTiles(title: "Holiday Packages", image: "home-cat-icon-Holiday", backgroundImage: "home-cat-Holiday", segue: "toHotelList", listType: .packages),
                     HomeTiles(title: "Activities", image: "home-cat-icon-Activities", backgroundImage: "home-cat-Activities", segue: "toHotelList", listType: .activities),
                     HomeTiles(title: "Meetups", image: "home-cat-icon-Meetups", backgroundImage: "home-cat-Meetups", segue: "toHotelList", listType: .meetups)]
        sections = [HomeSection(type: .banner, count: banners.count),
                    HomeSection(type: .tiles, count: homeTiles.count)]
        
        
        let locale = Locale.current
        if #available(iOS 16, *) {
            print("Locale: \(locale.region?.identifier)")
        } else {
            // Fallback on earlier versions
            print("Locale (before iOS 16): \(locale.regionCode)")
        }
        
        getBanners()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getBanners()
    }
    
    func testURL() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tripsmanhexeam.page.link"
        components.path = "/resetPassword"
        
        let tokenQueryItem = URLQueryItem(name: "token", value: "abakjfbak282892jakwdn82nduka")
        let emailQueryItem = URLQueryItem(name: "email", value: "test@test.com")
        components.queryItems = [tokenQueryItem, emailQueryItem]
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ListingViewController {
            if let listType = sender as? ListType {
                vc.listType = listType
            }
        }
    }
    
    
    @IBAction func buttonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
}

//MARK: - ApiCalls
extension MainViewController {
    func getBanners() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerBanner/GetCustomerBannerList?Type=home", http: .get, parameters: nil) { (result: BannerData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                self.refreshControl.endRefreshing()
                if error == nil {
                    if result!.status == 1 {
                        self.banners = result!.data
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

//MARK: - UICollectionView
extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = self.sections?[section] else { return 0 }
        
        if thisSection.type == .banner {
            return banners.count
        }
        
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = self.sections?[indexPath.section] else { return UICollectionViewCell()  }
        
        if thisSection.type == .banner {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath) as! HomeBannerCollectionViewCell
            cell.bannerImage.sd_setImage(with: URL(string: banners[indexPath.row].url))
            
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "homeBannerFooter", for: indexPath) as! HomeBannerFooterView
            
            footerView.configure(with: banners.count)
            
            footerView.subscribeTo(subject: pagingInfoSubject, for: indexPath.section)
            
            return footerView
            
        default:
            return UICollectionReusableView()
//            assert(false, "Invalid Element Type")
        }
    }
    
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let thisSection = sections?[indexPath.section] else { return }
        
        if thisSection.type == .tiles {
            guard let segue = homeTiles[indexPath.row].segue else { return }
            performSegue(withIdentifier: segue, sender: homeTiles[indexPath.row].listType)
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
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(10)
                
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .absolute(20))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                
                
                section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.boundarySupplementaryItems = [sectionFooter]
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: -30, trailing: 0)
                
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }
                    
                    let page = round(offset.x / self.view.bounds.width)
                    
                    self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }

                
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 8, bottom: 20, trailing: 8)
                return section
                
            } else {
                fatalError("Unknown section!")
            }
            
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}
