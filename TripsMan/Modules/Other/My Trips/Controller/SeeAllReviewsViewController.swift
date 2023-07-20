//
//  SeeAllReviewsViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 03/03/23.
//

import UIKit

class SeeAllReviewsViewController: UIViewController {
    
    @IBOutlet weak var reviewsCollection: UICollectionView! {
        didSet {
            reviewsCollection.collectionViewLayout = createLayout()
            reviewsCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            reviewsCollection.dataSource = self
        }
    }
    
    var reviewManager: AllReviewsManager?
    var reviews: [HotelReview]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Reviews".localized()

        if let reviews = reviews {
            reviewManager = AllReviewsManager(reviews: reviews)
            reviewsCollection.reloadData()
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension SeeAllReviewsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return reviewManager?.getSections()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let thisSection = reviewManager?.getSections()?[section] else { return 0 }
        return thisSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let thisSection = reviewManager?.getSections()?[indexPath.section] else { return UICollectionViewCell() }
        
        if thisSection.type == .review {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allReviewsCell", for: indexPath) as! AllReviewsCollectionViewCell
            
            if let review = reviewManager?.getReviews()?[indexPath.row] {
                cell.reviewTitle.text = review.reviewTitle
                cell.reviewText.text = review.hotelReview
                cell.ratingLabel.text = review.hotelRating?.stringValue()
                cell.dateAndName.text = " " + L.reviewedByText(by: review.customerName, on: review.reviewDate.date("dd/MM/yyyy HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")
            }
            
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
}

extension SeeAllReviewsViewController {
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                        
            guard let thisSection = self.reviewManager?.getSections()?[sectionIndex] else { return nil }
            let section: NSCollectionLayoutSection
            
            if thisSection.type == .review {
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

