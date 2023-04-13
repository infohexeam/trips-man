//
//  ListingManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 16/02/23.
//

import Foundation

struct ListingManager {
    
    enum SectionTypes {
        case list
        case banner
        case zeroData
    }
    
    struct ListingSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [ListingSection]? = nil
    var hotels: [Hotel]?
    var banners: [Banners]?
    var packages: [HolidayPackage]?
    
    var listingData: [ListingData]?
    
//    init(hotels: [Hotel]?, banners: [Banners]?) {
//        self.hotels = hotels
//        self.banners = banners
//
//        setSections()
//
//    }
    
    mutating func setSections() {
        if let hotels = hotels, hotels.count != 0 {
            if let banners = banners, banners.count != 0 {
                sections = [ListingSection(type: .list, count: hotels.count > 4 ? 4 : hotels.count),
                            ListingSection(type: .banner, count: banners.count),
                            ListingSection(type: .list, count: hotels.count > 4 ? (hotels.count - 4) : 0)]
            } else {
                sections = [ListingSection(type: .list, count: hotels.count)]
            }
        } else if let packages = packages, packages.count != 0 {
            if let banners = banners, banners.count != 0 {
                sections = [ListingSection(type: .list, count: packages.count > 4 ? 4 : packages.count),
                            ListingSection(type: .banner, count: banners.count),
                            ListingSection(type: .list, count: packages.count > 4 ? (packages.count - 4) : 0)]
            } else {
                sections = [ListingSection(type: .list, count: packages.count)]
            }
        } else {
            sections = [ListingSection(type: .zeroData, count: 1)]
        }
    }
    
    mutating func getSections() -> [ListingSection]? {
        return sections
    }
    
    mutating func assignHotels(hotels: [Hotel]?) {
        self.hotels = hotels
        setListingData(.hotel)
        setSections()
    }
    
    mutating func assignBanners(banners: [Banners]?) {
        self.banners = banners
        setSections()
    }
    
    mutating func assignPackages(packages: [HolidayPackage]?) {
        self.packages = packages
        setListingData(.packages)
        setSections()
    }
    
    func getBanners() -> [Banners]? {
        return banners
    }
    
    func getListingData() -> [ListingData]? {
        return listingData
    }
    
    mutating func setListingData(_ type: ListType) {
        listingData = [ListingData]()
        switch type {
        case .hotel:
            for hotel in hotels! {
                var starRating = ""
                for _ in 0..<hotel.hotelStar {
                    starRating += "⭑"
                }
                
                var ratingText = ""
                if hotel.userRating >= 4.5 {
                    ratingText = "Excellent\n"
                } else if hotel.userRating >= 4 {
                    ratingText = "Very Good\n"
                } else if hotel.userRating >= 3 {
                    ratingText = "Good\n"
                }
                
                let userRating = UserRating(ratingCount: hotel.userRatingCount, rating: "\(hotel.userRating.rounded)/5", ratingText: "\(ratingText)(\(hotel.userRatingCount.oneOrMany("rating")))")
                
                listingData?.append(ListingData(type: .hotel, id: hotel.hotelID, listImage: hotel.imageUrl, placeHolderImage: K.hotelPlaceHolderImage, isSponsored: hotel.isSponsored, starRatingText: "\(starRating) \(hotel.hotelType)", userRating: userRating, listName: hotel.hotelName, secondText: hotel.hotelAddress, actualPrice: hotel.actualPrice, offerPrice: hotel.offerPrice, taxLabelText: "+ \(SessionManager.shared.getCurrency()) \(hotel.serviceChargeValue)\ntaxes & fee per night"))
            }
            
        case .packages:
            for package in packages! {
                listingData?.append(ListingData(type: .packages, id: package.packageID, listImage: package.holidayImage.filter { $0.isFeatured == 1 }.last?.imageURL, placeHolderImage: K.packagePlaceHolderImage, isSponsored: package.isSponsored, listName: package.packageName, secondText: "\(package.duration) - \(package.countryName)", actualPrice: package.costPerPerson, offerPrice: package.offerPrice, taxLabelText: "+ \(SessionManager.shared.getCurrency()) \(package.seviceCharge)\ntaxes & fee per person"))
            }
        case .activities:
            break
        case .meetups:
            break
        }
    }
    
}




enum ListType: Codable {
    case hotel
    case packages
    case activities
    case meetups
}
