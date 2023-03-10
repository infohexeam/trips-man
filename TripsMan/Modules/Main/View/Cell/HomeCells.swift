//
//  HomeCells.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 21/09/22.
//

import Foundation
import UIKit
import Combine


//Footer
class HomeBannerFooterView: UICollectionReusableView {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var pagingInfoToken: AnyCancellable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
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
    
    private func setupView() {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pagingInfoToken?.cancel()
        pagingInfoToken = nil
    }
}


class HomeBannerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bannerImage: UIImageView!
}

class HomeTileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleIcon: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
}


struct PagingInfo: Equatable, Hashable {
    let sectionIndex: Int
    let currentPage: Int
}
