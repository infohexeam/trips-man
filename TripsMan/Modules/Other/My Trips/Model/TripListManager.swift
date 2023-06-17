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
        var module: ListType
        var bookingID: Int
        var tripStatus: Int
        var imageUrl: String
        var defaultImage: String
        var name: String
        var topLabel: String
        var subLabel: String
        var bottomLabels: [BottomLabel]
    }
    
    struct BottomLabel {
        var icon: String
        var text: String
    }
    
    init(myTrips: [MyTrips]?) {
        self.myTrips = myTrips
        setTripsToShow()
    }
    
    mutating func setTripsToShow() {
        tripsToShow = [TripsToShow]()
        if let myTrips = myTrips {
            for trip in myTrips {
                if trip.module == "HTL" {
                    let checkin = trip.checkInDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let checkout = trip.checkOutDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let topLabel = "\(trip.tripStatus) | \(checkin ?? "") - \(checkout ?? "")"
                    
                    let subLabel = trip.bookedDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMM dd, yyyy") ?? ""
                    
                    let bottomLabels = [BottomLabel(icon: "person.fill", text: trip.primaryGuest),
                                        BottomLabel(icon: "bed.double.fill", text: trip.roomCount.oneOrMany("Room"))]
                    
                    tripsToShow?.append(TripsToShow(module: .hotel, bookingID: trip.bookingID, tripStatus: trip.tripStatusValue, imageUrl: trip.imageURL ?? "", defaultImage: K.hotelPlaceHolderImage, name: trip.name, topLabel: topLabel, subLabel: subLabel, bottomLabels: bottomLabels))
                } else if trip.module == "HDY" {
                    let fromDate = trip.checkInDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let toDate = trip.checkOutDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let topLabel = "\(trip.tripStatus) | \(fromDate ?? "") - \(toDate ?? "")"
                    
                    let subLabel = trip.bookedDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMM dd, yyyy") ?? ""
                    
                    var countText = "\(trip.adultCount.oneOrMany("Adult"))"
                    if trip.childCount > 0 {
                        countText += " & \(trip.childCount.oneOrMany("Child", suffix: "ren"))"
                    }
                    
                    let bottomLabels = [BottomLabel(icon: "person.fill", text: trip.primaryGuest),
                                        BottomLabel(icon: "person.2.fill", text: countText)]
                    
                    tripsToShow?.append(TripsToShow(module: .packages, bookingID: trip.bookingID, tripStatus: trip.tripStatusValue, imageUrl: trip.imageURL ?? "", defaultImage: K.packagePlaceHolderImage, name: trip.name, topLabel: topLabel, subLabel: subLabel, bottomLabels: bottomLabels))
                    
                } else if trip.module == "ACT" {
                    let fromDate = trip.checkInDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
//                    let toDate = trip.checkOutDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let topLabel = "\(trip.tripStatus) | \(fromDate ?? "")"
                    
                    let subLabel = trip.bookedDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMM dd, yyyy") ?? ""
                                        
                    let bottomLabels = [BottomLabel(icon: "person.fill", text: trip.primaryGuest),
                                        BottomLabel(icon: "person.2.fill", text: trip.adultCount.oneOrMany("Member"))]
                    
                    tripsToShow?.append(TripsToShow(module: .activities, bookingID: trip.bookingID, tripStatus: trip.tripStatusValue, imageUrl: trip.imageURL ?? "", defaultImage: K.activityPlaceholderImage, name: trip.name, topLabel: topLabel, subLabel: subLabel, bottomLabels: bottomLabels))
                    
                } else if trip.module == "MTP" {
                    let meetupDate = trip.checkOutDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM")
                    let topLabel = "\(trip.tripStatus) | \(meetupDate ?? "")"
                    
                    let subLabel = trip.bookedDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "MMM dd, yyyy") ?? ""
                                        
                    let bottomLabels = [BottomLabel(icon: "person.fill", text: trip.primaryGuest),
                                        BottomLabel(icon: "person.2.fill", text: trip.adultCount.oneOrMany("Member"))]
                    
                    tripsToShow?.append(TripsToShow(module: .packages, bookingID: trip.bookingID, tripStatus: trip.tripStatusValue, imageUrl: trip.imageURL ?? "", defaultImage: K.meetupPlaceholderImage, name: trip.name, topLabel: topLabel, subLabel: subLabel, bottomLabels: bottomLabels))
                }
            }
        }
    }
    
    func getTripsToShow() -> [TripsToShow]? {
        return tripsToShow
    }
}
