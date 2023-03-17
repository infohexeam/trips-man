//
//  FilterManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/03/23.
//

import Foundation

struct FilterManager {
    var hotelFilters: HotelListingFilters?
    
    init(hotelFilters: HotelListingFilters? = nil) {
        self.hotelFilters = hotelFilters
    }
    
    mutating func setRoomQty(_ qty: Int) {
        self.hotelFilters?.roomCount = qty
    }
    
    mutating func setAdultQty(_ qty: Int) {
        self.hotelFilters?.adult = qty
    }
    
    mutating func setChildQty(_ qty: Int) {
        self.hotelFilters?.child = qty
    }
    
    
    
    
}
