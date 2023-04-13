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
    var rewardPoint = 0.0
    var selectedCoupon = ""
    
    init(packagbooking: PackageBooking?) {
        self.bookingData = packagbooking
        self.packageDetails = packagbooking?.packageDetails
        setSections()
    }
    
    init(packageBooking: PackageBooking?, coupons: [Coupon]?, rewardPoints: Double) {
        self.bookingData = packageBooking
        self.packageDetails = packageBooking?.packageDetails
        self.coupons = coupons
        self.rewardPoint = rewardPoints
        setSections()
    }
    
    func getSections() -> [PackageSummarySection]? {
        return sections
    }
    
    mutating func setSections() {
        print("booking data is \(bookingData)")
        if bookingData != nil {
            if coupons == nil {
                if let others = bookingData?.holidayGuests.filter({ $0.isPrimary == 0 }) {
                    print("\n\n----------------1")
                    sections = [PackageSummarySection(type: .packageSummary, count: 1),
                                PackageSummarySection(type: .primaryTraveller, count: 1),
                                PackageSummarySection(type: .otherTravellers, count: others.count),
                                PackageSummarySection(type: .bottomView, count: bookingData!.amountDetails.count)]
                } else {
                    print("\n\n----------------2")
                    sections = [PackageSummarySection(type: .packageSummary, count: 1),
                                PackageSummarySection(type: .primaryTraveller, count: 1),
                                PackageSummarySection(type: .bottomView, count: bookingData!.amountDetails.count)]
                }
                
            } else {
                print("\n\n----------------3")
                if let others = bookingData?.holidayGuests.filter({ $0.isPrimary == 0 }) {
                    print("\n\n----------------1")
                    sections = [PackageSummarySection(type: .packageSummary, count: 1),
                                PackageSummarySection(type: .primaryTraveller, count: 1),
                                PackageSummarySection(type: .otherTravellers, count: others.count),
                                PackageSummarySection(type: .seperator, count: 1),
                                PackageSummarySection(type: .coupon, count: coupons!.count),
                                PackageSummarySection(type: .bottomView, count: bookingData!.amountDetails.count)]
                } else {
                    print("\n\n----------------2")
                    sections = [PackageSummarySection(type: .packageSummary, count: 1),
                                PackageSummarySection(type: .primaryTraveller, count: 1),
                                PackageSummarySection(type: .seperator, count: 1),
                                PackageSummarySection(type: .coupon, count: coupons!.count),
                                PackageSummarySection(type: .bottomView, count: bookingData!.amountDetails.count)]
                }
                
            }
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
        if let coupons = coupons {
            if coupons.count > K.couponToShow {
                return Array(coupons[...(K.couponToShow-1)])
            } else {
                return coupons
            }
        }
        return nil
    }
    
    func getSelectedCoupon() -> String {
        return selectedCoupon
    }
    
    func getAmountDetails() -> [AmountDetail]? {
        return bookingData?.amountDetails
    }
}
