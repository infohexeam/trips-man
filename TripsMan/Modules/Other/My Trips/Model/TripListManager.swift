//
//  TripListManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 11/05/23.
//

import Foundation

struct TripListManager {
    
    var myTrips: [MyTrips]?
    var tripsToShow: [TripsToShow]?
    
    struct TripsToShow {
        var bookingID: Int
        var imageUrl: String
        var name: String
        var topLabel: String
        var subLabel: String
    }
    
    struct BottomLabel {
        var icon: String
        var text: String
    }
    
    init(myTrips: [MyTrips]?) {
        self.myTrips = myTrips
    }
    
    mutating func getTripsToShow() -> [TripsToShow]? {
        tripsToShow = [TripsToShow]()
        if let myTrips = myTrips {
            for trip in myTrips {
                if trip.module == "HTL" {
                    let topLabel = ""
                }
            }
        }
        
        return nil
    }
    
}
