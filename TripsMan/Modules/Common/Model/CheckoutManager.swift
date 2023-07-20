//
//  CheckoutManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 31/05/23.
//

import Foundation

struct CheckoutManager {
    enum SectionTypes {
        case priceDetails
        case seperator
        case paymentMethod
        case reward
    }
    
    struct CheckoutSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [CheckoutSection]? = nil
    var checkouData: Checkout?
    var amountDetails: [Amount]?
    
    init(checkoutData: Checkout?, amounts: [Amount]?) {
        self.checkouData = checkoutData
        if let amounts = amounts {
            self.amountDetails = amounts
        } else {
            self.amountDetails = checkoutData?.amounts
        }
        setSections()
    }
    
    
    func getSections() -> [CheckoutSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let checkouData = checkouData {
            sections = [CheckoutSection(type: .priceDetails, count: amountDetails?.count ?? 0),
                        CheckoutSection(type: .paymentMethod, count: 1),
                        CheckoutSection(type: .reward, count: 1)]
        }
    }
    
    func getCheckoutDetails() -> Checkout? {
        return self.checkouData
    }
    
    func getAmountDetails() -> [Amount]? {
        return self.amountDetails
    }
    
}
