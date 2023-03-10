//
//  CouponData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 01/02/23.
//

import Foundation

// MARK: - CouponData
struct CouponData: Codable {
    let data: CouponDataClass
    let status: Int
    let message: String
}

//MARK: - CuponDataClass
struct CouponDataClass: Codable {
    let rewardPoint: Double
    let coupon: [Coupon]
}

// MARK: - Coupon
struct Coupon: Codable {
    let couponName, couponCode, validFrom: String
    let validTo, description: String
    let minOrderValue, discountType, discountAmount, status: Int
    let couponID: Int

    enum CodingKeys: String, CodingKey {
        case couponName, couponCode, validFrom, validTo, description, minOrderValue, discountType, discountAmount, status
        case couponID = "couponId"
    }
}


// MARK: - ApplyCouponData
struct ApplyCouponData: Codable {
    let data: ApplyCoupon?
    let status: Int
    let message: String
}

// MARK: - ApplyCoupon
struct ApplyCoupon: Codable {
    let coupon: Coupon
    let amounts: [AmountDetail]
}

//MARK: - RemoveCouponData
struct RemoveCouponData: Codable {
    let data: [AmountDetail]
    let status: Int
    let message: String
}
