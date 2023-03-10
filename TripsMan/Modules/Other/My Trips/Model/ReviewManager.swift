//
//  ReviewManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 02/03/23.
//

import Foundation

struct ReviewManager {
    struct Review {
        var rating: Double?
        var reviewTitle: String?
        var reviewText: String?
    }
    
    func isReviewValid(review: Review) -> (Bool, String) {
        var isValid = true
        var message = ""
        
        if review.rating == 0 {
            isValid = false
            message = "Please add a rating"
        } else if review.reviewTitle != "" && review.reviewText == "" {
            isValid = false
            message = "Please enter your review"
        } else if review.reviewTitle == "" && review.reviewText != "" {
            isValid = false
            message = "Please enter review title"
        }
        
        return (isValid, message)
    }
    
    func isEdit(_ tripDetails: TripDetails?) -> Bool {
        if tripDetails?.review != nil {
            return true
        }
        return false
    }

}

struct AllReviewsManager {
    enum SectionTypes {
        case review
    }
    
    struct AllReviewSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [AllReviewSection]? = nil
    var reviews: [HotelReview]?
    
    init(reviews: [HotelReview]) {
        self.reviews = reviews
        setSections()
    }
    
    func getSections() -> [AllReviewSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let reviews = reviews {
            sections = [AllReviewSection(type: .review, count: reviews.filter({ $0.hotelReview != "" }).count)]
        }
    }
    
    func getReviews() -> [HotelReview]? {
        return reviews?.filter { $0.hotelReview != "" }
    }
}



