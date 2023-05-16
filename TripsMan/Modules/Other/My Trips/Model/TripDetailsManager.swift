//
//  TripDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/05/23.
//

import Foundation

struct TripDetailsManager {
    
    var hotelTripDetails: HotelTripDetails?
    
    var detailsData: DetailsData?
    
    struct DetailsData {
        var topBox: TopBox
        var secondBox: SecondBox
        var thirdBox: ThirdBox
    }
    
    struct TopBox {
        var tripStatus: String
        var bookingNo: String
        var bookedDate: String
        var tripMessage: String
    }
    
    struct SecondBox {
        var image: String
        var name: String
        var address: String
    }
    
    struct ThirdBox {
        var fromDate: DateLabels
        var toDate: DateLabels?
        var roomAndGuestCount: String?
        var roomType: String?
        var primaryGuest: PrimaryGuest
        var otherGuests: OtherGuest?
    }
    
    struct DateLabels {
        var label: String
        var date: String
        var time: String?
    }
    
    struct PrimaryGuest {
        var label: String
        var nameText: String
        var contact: String
    }
    
    struct OtherGuest {
        var label: String
        var text: String
    }
        
    init(hotelTripDetails: HotelTripDetails?) {
        self.hotelTripDetails = hotelTripDetails
        setDetailsData()
    }
    
    mutating func setDetailsData() {
        if let hotelTripDetails = hotelTripDetails {
            let topBox = TopBox(tripStatus: hotelTripDetails.tripStatus, bookingNo: "BOOKING ID - \(hotelTripDetails.bookingNo ?? "")", bookedDate: "Booked on \(hotelTripDetails.bookingDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")", tripMessage: hotelTripDetails.tripMessage)
            let secondBox = SecondBox(image: hotelTripDetails.imageURL ?? "", name: hotelTripDetails.hotelName, address: hotelTripDetails.hotelDetails.address)
            
            let fromDate = DateLabels(label: "Check-in", date: hotelTripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "", time: hotelTripDetails.hotelDetails.checkInTime?.date("HH:mm:ss")?.stringValue(format: "HH:mm: a"))
            let toDate = DateLabels(label: "Check-out", date: hotelTripDetails.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "", time: hotelTripDetails.hotelDetails.checkOutTime?.date("HH:mm:ss")?.stringValue(format: "HH:mm: a"))
            let roomAndGuestCount = "\(hotelTripDetails.roomCount.oneOrMany("Room")) for \(hotelTripDetails.adultCount.oneOrMany("Adult")), \(hotelTripDetails.childCount.oneOrMany("Child", suffix: "ren"))"
            let primary = hotelTripDetails.hotelGuests.filter({ $0.isPrimary == 1}).last
            let primaryGuest = PrimaryGuest(label: "Primary Guest", nameText: "\(primary?.guestName ?? ""), \(primary?.gender ?? "") \(primary?.age.intValue().oneOrMany("yr") ?? "")", contact: "\(primary?.email ?? "")\n\(primary?.contactNo ?? "")")
            let others = hotelTripDetails.hotelGuests.filter({ $0.isPrimary == 0})
            var otherGuestText = ""
            for other in others {
                otherGuestText += "\(other.guestName), \(other.gender) \(other.age.intValue().oneOrMany("yr"))\n"
            }
            let otherGuest = OtherGuest(label: "Other Guests", text: otherGuestText.trimmingCharacters(in: .whitespacesAndNewlines))
            
            let thirdBox = ThirdBox(fromDate: fromDate, toDate: toDate, roomAndGuestCount: roomAndGuestCount, roomType: hotelTripDetails.roomDetails.count > 0 ? hotelTripDetails.roomDetails[0].roomType : "", primaryGuest: primaryGuest, otherGuests: otherGuest.text == "" ? nil : otherGuest)
            
            detailsData = DetailsData(topBox: topBox, secondBox: secondBox, thirdBox: thirdBox)
        }
    }
    
    func getDetailsData() -> DetailsData? {
        return detailsData
    }
}
