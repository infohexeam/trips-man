//
//  PackageSummaryManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/04/23.
//

import Foundation

struct PackageSummaryManager {
    enum SectionTypes {
        case packageSummary
        case primaryTraveller
        case otherTravellers
        case coupon
        case seperator
        case bottomView
    }
    
    struct PackageSummarySection {
        let type: SectionTypes
        let count: Int
        
        init(type: SectionTypes, count: Int) {
            self.type = type
            self.count = count
        }
        
    }
    
    var sections: [PackageSummarySection]? = nil
    var bookingData: PackageBooking?
    var packageDetails: SummaryPackageDetails?
    var coupons: [Coupon]?
    var couponsToShow: [Coupon]?
    var rewardPoint = 0.0
    var selectedCoupon: String?
    var amountDetails: [AmountDetail]?
    
    init(packagbooking: PackageBooking?) {
        self.bookingData = packagbooking
        self.packageDetails = packagbooking?.packageDetails
        self.amountDetails = packagbooking?.amountDetails
        setSections()
    }
    
    init(packageBooking: PackageBooking?, coupons: [Coupon]?, rewardPoints: Double) {
        self.bookingData = packageBooking
        self.packageDetails = packageBooking?.packageDetails
        self.amountDetails = packageBooking?.amountDetails
        self.coupons = coupons
        self.rewardPoint = rewardPoints
        setCouponsTOShow()
        setSections()
    }
    
    func getSections() -> [PackageSummarySection]? {
        return sections
    }
    
    mutating func setSections() {
        if bookingData != nil {
            
            sections = [PackageSummarySection(type: .packageSummary, count: 1),
                        PackageSummarySection(type: .primaryTraveller, count: 1)]
            if let others = bookingData?.holidayGuests.filter({ $0.isPrimary == 0 }) {
                if others.count != 0 {
                    sections?.append(PackageSummarySection(type: .otherTravellers, count: others.count))
                }
            }
            sections?.append(PackageSummarySection(type: .seperator, count: 1))
            if coupons != nil {
                sections?.append(PackageSummarySection(type: .coupon, count: couponsToShow!.count))
            }
            sections?.append(PackageSummarySection(type: .bottomView, count: bookingData!.amountDetails.count))
        }
    }
    
    func getBookingSummary() -> PackageBooking? {
        return self.bookingData
    }
    
    func getPackageDetails() -> SummaryPackageDetails? {
        return self.packageDetails
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
            setSections()
        }
    }
    
    mutating func setSelectedCoupon(_ coupon: Coupon?, amountDetails: [AmountDetail], showSingleCoupon: Bool = false) {
        self.selectedCoupon = coupon?.couponCode
        self.amountDetails = amountDetails
        if coupon != nil {
            if showSingleCoupon {
                couponsToShow = [coupon!]
                setSections()
            }
        } else {
            setCouponsTOShow()
        }
    }
    
    func getSelectedCoupon() -> String? {
        return selectedCoupon
    }
    
    func getAmountDetails() -> [AmountDetail]? {
        return self.amountDetails
    }
}
