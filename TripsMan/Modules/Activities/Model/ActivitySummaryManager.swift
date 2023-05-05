//
//  ActivitySummaryManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/04/23.
//

import Foundation

struct ActivitySummaryManager {
    enum SectionTypes {
        case summary
        case customerDetails
        case seperator
        case coupon
        case reward
        case priceDetails
    }

    
    struct ActivitySummarySection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [ActivitySummarySection]? = nil
    var bookingData: ActivityBooking?
    var coupons: [Coupon]?
    var couponsToShow: [Coupon]?
    var rewardPoint = 0.0
    var selectedCoupon: String?
    var amountDetails: [AmountDetail]?
    
    init(activityBooking: ActivityBooking?) {
        self.bookingData = activityBooking
        self.amountDetails = activityBooking?.amountDetails
        setSections()
    }
    
    init(activityBooking: ActivityBooking?, coupons: [Coupon]?, rewardPoints: Double) {
        self.bookingData = activityBooking
        self.amountDetails = activityBooking?.amountDetails
        self.coupons = coupons
        self.rewardPoint = rewardPoints
        setCouponsTOShow()
        setSections()
    }
    
    func getSections() -> [ActivitySummarySection]? {
        return sections
    }
    
    mutating func setSections() {
        if bookingData != nil {
            sections = [ActivitySummarySection(type: .summary, count: 1),
                        ActivitySummarySection(type: .customerDetails, count: 1)]
            sections?.append(ActivitySummarySection(type: .seperator, count: 1))
            if coupons != nil {
                sections?.append(ActivitySummarySection(type: .coupon, count: couponsToShow!.count))
            }
            if rewardPoint > 0 {
                sections?.append(ActivitySummarySection(type: .reward, count: 1))
            }
            sections?.append(ActivitySummarySection(type: .priceDetails, count: bookingData!.amountDetails.count))
        }
    }
    
    func getBookingSummary() -> ActivityBooking? {
        return self.bookingData
    }
    
    func getSection(_ type: SectionTypes) -> Int? {
        if sections != nil {
            for i in 0..<sections!.count {
                if sections![i].type == type {
                    return i
                }
            }
        }
        return nil
    }
    
    func getCouponsToShow() -> [Coupon]? {
        return couponsToShow
    }
    
    func getAllCoupons() -> [Coupon]? {
        return coupons
    }
    
    mutating func setCouponsTOShow() {
        if let coupons = coupons {
            if coupons.count > K.couponToShow {
                couponsToShow = Array(coupons[...(K.couponToShow-1)])
            } else {
                couponsToShow = coupons
            }
        }
    }
    
    mutating func setSelectedCoupon(_ coupon: Coupon?, amountDetails: [AmountDetail], showSingleCoupon: Bool = false) {
        self.selectedCoupon = coupon?.couponCode
        self.amountDetails = amountDetails
        if coupon != nil {
            if showSingleCoupon {
                couponsToShow = [coupon!]
            }
        } else {
            setCouponsTOShow()
        }
    }
    
    func getSelectedCoupon() -> String? {
        return selectedCoupon
    }
    
    func getAmountDetails() -> [AmountDetail]? {
        return bookingData?.amountDetails
    }
}
