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
    var activities: [Activity]?
    var meetups: [Meetup]?
    
    var listingData: [ListingData]?
    
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
        } else if let activities = activities, activities.count != 0 {
            sections = [ListingSection(type: .list, count: activities.count)]
        } else if let meetups = meetups, meetups.count != 0 {
            sections = [ListingSection(type: .list, count: meetups.count)]
        } else {
            sections = [ListingSection(type: .zeroData, count: 1)]
        }
    }
    
    mutating func getSections() -> [ListingSection]? {
        return sections
    }
    
    mutating func assignHotels(hotels: [Hotel]?, offset: Int) {
        if offset > 0 {
            if let hotels = hotels {
                self.hotels?.append(contentsOf: hotels)
            }
        } else {
            self.hotels = hotels
        }
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
    
    mutating func assignActivities(activities: [Activity]?) {
        self.activities = activities
        setListingData(.activities)
        setSections()
    }
    
    mutating func assignMeetups(meetups: [Meetup]?) {
        self.meetups = meetups
        setListingData(.meetups)
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
                var packageImage = package.holidayImage.filter { $0.isFeatured == 1 }.last?.imageURL
                if packageImage == nil {
                    if package.holidayImage.count > 0 {
                        packageImage = package.holidayImage[0].imageURL
                    }
                }
                listingData?.append(ListingData(type: .packages, id: package.packageID, listImage: packageImage, placeHolderImage: K.packagePlaceHolderImage, isSponsored: package.isSponsored, listName: package.packageName, secondText: "\(package.duration) - \(package.countryName)", actualPrice: package.costPerPerson, offerPrice: package.offerPrice, taxLabelText: "+ \(SessionManager.shared.getCurrency()) \(package.serviceCharge)\ntaxes & fee per person"))
            }
        case .activities:
            for activity in activities! {
                listingData?.append(ListingData(type: .activities, id: activity.activityID, listImage: activity.activityImages.filter { $0.isFeatured == 1 }.last?.imageURL, placeHolderImage: K.activityPlaceholderImage, isSponsored: activity.isSponsored, listName: activity.activityName, secondText: activity.activityLocation, actualPrice: activity.costPerPerson, offerPrice: activity.offerPrice, taxLabelText: "+ \(SessionManager.shared.getCurrency()) \(activity.serviceChargeValue ?? 0)\ntaxes & fee per person"))
            }
        case .meetups:
            for meetup in meetups! {
                listingData?.append(ListingData(type: .meetups, id: meetup.meetupID, listImage: meetup.meetupImages.filter { $0.isFeatured == 1 }.last?.imageURL, placeHolderImage: K.meetupPlaceholderImage, isSponsored: 0, listName: meetup.meetupName, secondText: "\(meetup.meetupDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM") ?? "nil")", actualPrice: 1111, offerPrice: 0, taxLabelText: "+ \(SessionManager.shared.getCurrency()) 0\ntaxes & fee per person"))
            }
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
