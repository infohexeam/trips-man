//
//  HotelDetailCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 26/09/22.
//

import Foundation
import UIKit
import MapKit
import Cosmos
import Combine

class HotelImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hotelImage: UIImageView!
}

class HotelDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var starRating: UILabel!
    @IBOutlet weak var readMoreView: UIView!
    @IBOutlet weak var detailsHiddenLabel: UILabel!
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        delegate?.showReadMore(for: .details, content: nil)
    }
}

class HotelAddrressCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressMap: MKMapView!
}

class HotelFacilitiesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var facilityLabel: UILabel!
    @IBOutlet weak var facilityIcon: UIImageView!
    @IBOutlet weak var moreView: UIView!
    
}

class SeperatorCell: UICollectionViewCell {
    
}

class RoomFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hotelNameLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    
    //Not in use
    
    @IBOutlet weak var checkinField: CustomTextField!
    @IBOutlet weak var checkoutField: CustomTextField!
    
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var adultLabel: UILabel!
    @IBOutlet weak var childLabel: UILabel!
    
    @IBOutlet weak var roomAddButton: UIButton!
    @IBOutlet weak var roomMinusButton: UIButton!
    @IBOutlet weak var adultAddButton: UIButton!
    @IBOutlet weak var adultMinusButton: UIButton!
    @IBOutlet weak var childAddButton: UIButton!
    @IBOutlet weak var childMinusButton: UIButton!
    
    var roomQty = 0 {
        didSet {
            roomLabel.text = roomQty.oneOrMany("Room")
        }
    }
    
    var adultQty = 0 {
        didSet {
            adultLabel.text = adultQty.oneOrMany("Adult")
        }
    }
    
    var childQty = 0 {
        didSet {
            childLabel.text = childQty.oneOrMany("Child", suffix: "ren")
        }
    }
    
    var checkin = "" {
        didSet {
            checkinField.text = checkin
        }
    }
    var checkout = "" {
        didSet {
            checkoutField.text = checkout
        }
    }
    
    func setupView() {
        roomQty = 1
        adultQty = 1
        childQty = 0
    }
    
    func addOrMinusPeople(_ sender: UIButton) {
        if sender == roomAddButton {
            roomQty += 1
        } else if sender == roomMinusButton {
            if roomQty > 1 {
                roomQty -= 1
            }
        } else if sender == adultAddButton {
            adultQty += 1
        } else if sender == adultMinusButton {
            if adultQty > 1 {
                adultQty -= 1
            }
        } else if sender == childAddButton {
            childQty += 1
        } else if sender == childMinusButton {
            if childQty > 0 {
                childQty -= 1
            }
        }
    }
    
    @IBAction func addOrMinusTapped(_ sender: UIButton) {
        addOrMinusPeople(sender)
    }
}

class HotelRoomsCollectionViewCell: UICollectionViewCell {
    
    var delegate: RoomCellDelegate?
    var hasRoomImage = false
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var roomImage: UIImageView!
    @IBOutlet weak var offLabel: UILabel!
    
    @IBOutlet weak var soldOutView: UIView!
    @IBOutlet weak var roomName: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var multipleButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var viewMoreButton: UIButton!
    
    @IBAction func imageTapped(_ sender: UIButton) {
        if hasRoomImage {
            delegate?.imageTapped(sender.tag)
        }
    }
    
    @IBAction func viewMoreTapped(_ sender: UIButton) {
        delegate?.viewMoreTapped(sender.tag)
    }
    
    @IBAction func selectTapped(_ sender: UIButton) {
        delegate?.selectTapped(sender.tag)
    }
    
}

class PropertyRulesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ruleLabel: UILabel!
    @IBOutlet weak var readMoreView: UIView!
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        delegate?.showReadMore(for: .rules, content: nil)
    }
    
}

class TermsCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var readMoreView: UIView!
    
    var delegate: ReadMoreDelegate?
    
    @IBAction func readMoreDidTapped(_ sender: UIButton) {
        print("\n terms clikced")
        delegate?.showReadMore(for: .terms, content: termsLabel.attributedText)
    }
    
}

class RatingCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var rating: CosmosView!
    
}

class ReviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var customerImage: UIImageView!
    @IBOutlet weak var reviewTitle: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var review: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var seeAllreviewButton: UIButton!
    
}

class ImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var roomImage: UIImageView!
}


//Headers
class HotelDetailsHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
}

//Footer
class HotelDetailsFooterView: UICollectionReusableView {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var pagingInfoToken: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with numberOfPages: Int) {
        pageControl.numberOfPages = numberOfPages
    }
    
    func subscribeTo(subject: PassthroughSubject<PagingInfo, Never>, for section: Int) {
        pagingInfoToken = subject
            .filter { $0.sectionIndex == section }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] pagingInfo in
                self?.pageControl.currentPage = pagingInfo.currentPage
            }
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        pagingInfoToken?.cancel()
        pagingInfoToken = nil
    }
}



protocol RoomCellDelegate {
    func imageTapped(_ tag: Int)
    func viewMoreTapped(_ index: Int)
    func selectTapped(_ index: Int)
}
