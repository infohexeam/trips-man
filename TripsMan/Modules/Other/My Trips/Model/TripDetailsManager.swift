//
//  TripDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 15/05/23.
//

import Foundation

struct TripDetailsManager {
    
    enum SectionTypes {
        case tripDetails
        case secondDetails
        case priceDetails
        case review
        case action
    }
    
    struct TripDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [TripDetailsSection]? = nil
    
    var hotelTripDetails: HotelTripDetails?
    var holidayTripDetails: HolidayTripDetails?
    var activityTripDetails: ActivityTripDetails?
    var meetupTripDetails: MeetupTripDetails?
    
    var detailsData: DetailsData?
    var moreDetails: [MoreDetails]?
    
    var amountDetails: [AmountDetail]?
    
    struct DetailsData {
        var topBox: TopBox
        var secondBox: SecondBox
    }
    
    struct TopBox {
        var tripStatus: String
        var bookingNo: String
        var bookedDate: String
        var tripMessage: String
        var canDownloadTicket: Bool = false
    }
    
    struct SecondBox {
        var image: String
        var name: String
        var address: String
    }
    
    struct MoreDetails {
        var leftText: MoreDetailsObj?
        var rightText: MoreDetailsObj?
    }
    
    struct MoreDetailsObj {
        var title: String?
        var text: String?
        var subText: String?
    }
    
    init(hotelTripDetails: HotelTripDetails?) {
        self.hotelTripDetails = hotelTripDetails
        self.amountDetails = hotelTripDetails?.amountDetails
        setSections()
        setMoreDetails()
        setDetailsData()
    }
    
    init(holidayTripDetails: HolidayTripDetails?) {
        self.holidayTripDetails = holidayTripDetails
        self.amountDetails = holidayTripDetails?.amountdetails
        setSections()
        setMoreDetails()
        setDetailsData()
    }
    
    init(activityTripDetails: ActivityTripDetails?) {
        self.activityTripDetails = activityTripDetails
        self.amountDetails = activityTripDetails?.amountdetails
        setSections()
        setMoreDetails()
        setDetailsData()
    }
    
    init(meetupTripDetails: MeetupTripDetails?) {
        self.meetupTripDetails = meetupTripDetails
        self.amountDetails = meetupTripDetails?.amountDetails
        setSections()
        setMoreDetails()
        setDetailsData()
    }
    
    func getSections() -> [TripDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        //TripStatusValues:
        //0 - Upcoming
        //1 - Completed
        //2 - Ongoing
        //3 - Cancelled
        if let hotelTripDetails = hotelTripDetails {
            sections = [TripDetailsSection(type: .tripDetails, count: 1),
                        TripDetailsSection(type: .secondDetails, count: 3),
                        TripDetailsSection(type: .priceDetails, count: hotelTripDetails.amountDetails.count)]
            //Add review for completed bookings
            if hotelTripDetails.tripStatusValue == 1 {
                sections?.append(TripDetailsSection(type: .review, count: 1))
            }
            //Cancel for upcoming bookings
            if hotelTripDetails.tripStatusValue == 0 {
                sections?.append(TripDetailsSection(type: .action, count: 1))
            }
        } else if let holidayTripDetails = holidayTripDetails {
            sections = [TripDetailsSection(type: .tripDetails, count: 1),
                        TripDetailsSection(type: .secondDetails, count: 3),
                        TripDetailsSection(type: .priceDetails, count: holidayTripDetails.amountdetails.count)]
            
            //Cancel for upcoming bookings
            if holidayTripDetails.tripStatusValue == 0 {
                sections?.append(TripDetailsSection(type: .action, count: 1))
            }
        } else if let activityTripDetails = activityTripDetails {
            sections = [TripDetailsSection(type: .tripDetails, count: 1),
                        TripDetailsSection(type: .secondDetails, count: 2),
                        TripDetailsSection(type: .priceDetails, count:activityTripDetails.amountdetails.count)]
            
            //Cancel for upcoming bookings
            if activityTripDetails.tripStatusValue == 0 {
                sections?.append(TripDetailsSection(type: .action, count: 1))
            }
        } else if let meetupTripDetails = meetupTripDetails {
            sections = [TripDetailsSection(type: .tripDetails, count: 1),
                        TripDetailsSection(type: .secondDetails, count: 2),
                        TripDetailsSection(type: .priceDetails, count:meetupTripDetails.amountDetails.count)]
            
            //Cancel for upcoming bookings
            if meetupTripDetails.tripStatusValue == 0 {
                sections?.append(TripDetailsSection(type: .action, count: 1))
            }
        }

        
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
    
    mutating func setDetailsData() {
        //TripStatusValues:
        //0 - Upcoming
        //1 - Completed
        //2 - Ongoing
        //3 - Cancelled
        if let hotelTripDetails = hotelTripDetails {
            let topBox = TopBox(tripStatus: hotelTripDetails.tripStatus, bookingNo: "BOOKING ID".localized() + " - \(hotelTripDetails.bookingNo ?? "")", bookedDate: "Booked on" + " \(hotelTripDetails.bookingDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")", tripMessage: hotelTripDetails.tripMessage)
            let secondBox = SecondBox(image: hotelTripDetails.imageURL ?? "", name: hotelTripDetails.hotelName, address: hotelTripDetails.hotelDetails.address.capitalizedSentence)
            
            detailsData = DetailsData(topBox: topBox, secondBox: secondBox)
        } else if let holidayTripDetails = holidayTripDetails {
            let topBox = TopBox(tripStatus: holidayTripDetails.tripStatus, bookingNo: "BOOKING ID".localized() + " - \(holidayTripDetails.bookingNo)", bookedDate: "Booked on".localized() + " \(holidayTripDetails.bookingDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")", tripMessage: holidayTripDetails.tripMessage)
            
            let secondBox = SecondBox(image: holidayTripDetails.imageUrl, name: holidayTripDetails.packagedetails[0].packageName, address: holidayTripDetails.packagedetails[0].shortDescription)
            
            detailsData = DetailsData(topBox: topBox, secondBox: secondBox)
        } else if let activityTripDetails = activityTripDetails {
            var canDownloadTicket = true
            if activityTripDetails.tripStatusValue == 3 {
                canDownloadTicket = false
            }
            let topBox = TopBox(tripStatus: activityTripDetails.tripStatus, bookingNo: "BOOKING ID".localized() + " - \(activityTripDetails.bookingNo)", bookedDate: "Booked on".localized() + " \(activityTripDetails.bookingDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")", tripMessage: activityTripDetails.tripMessage, canDownloadTicket: canDownloadTicket)
            
            let secondBox = SecondBox(image: activityTripDetails.activitydetails[0].activityImage, name: activityTripDetails.activitydetails[0].activityName, address: activityTripDetails.activitydetails[0].shortDescription)
            
            detailsData = DetailsData(topBox: topBox, secondBox: secondBox)
        } else if let meetupTripDetails = meetupTripDetails {
            var canDownloadTicket = true
            if meetupTripDetails.tripStatusValue == 3 {
                canDownloadTicket = false
            }
            let topBox = TopBox(tripStatus: meetupTripDetails.tripStatus, bookingNo: "BOOKING ID".localized() + " - \(meetupTripDetails.bookingNo)", bookedDate: "Booked on".localized() + " \(meetupTripDetails.bookingDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "dd MMM yyyy") ?? "")", tripMessage: meetupTripDetails.tripMessage, canDownloadTicket: canDownloadTicket)
            
            let secondBox = SecondBox(image: meetupTripDetails.imageUrl ?? "", name: meetupTripDetails.meetupDetails.meetupName, address: meetupTripDetails.meetupDetails.shortDescription)
            
            detailsData = DetailsData(topBox: topBox, secondBox: secondBox)
        }
        
        
    }
    
    
    mutating func setMoreDetails() {
        if let hotelTripDetails = hotelTripDetails {
            moreDetails = [MoreDetails]()
            
            let left1 = MoreDetailsObj(title: "Check-in".localized(), text: hotelTripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "", subText: hotelTripDetails.hotelDetails.checkInTime?.date("HH:mm:ss")?.stringValue(format: "HH:mm: a"))
            let right1 = MoreDetailsObj(title: "Check-out".localized(), text: hotelTripDetails.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "", subText: hotelTripDetails.hotelDetails.checkOutTime?.date("HH:mm:ss")?.stringValue(format: "HH:mm: a"))
            let text1 = MoreDetails(leftText: left1, rightText: right1)
            
            
            let left2 = MoreDetailsObj(text: L.roomAndGuestCountText(roomCount: hotelTripDetails.roomCount, adultCount: hotelTripDetails.adultCount, childCount: hotelTripDetails.childCount))
            let right2 = MoreDetailsObj(text: hotelTripDetails.roomDetails.count > 0 ? hotelTripDetails.roomDetails[0].roomType : "", subText: hotelTripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.numberOfDays(to: hotelTripDetails.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss") ?? Date()).oneOrMany("Night"))
            let text2 = MoreDetails(leftText: left2, rightText: right2)
            
            
            let primary = hotelTripDetails.hotelGuests.filter({ $0.isPrimary == 1}).last
            let left3 = MoreDetailsObj(title: "Primary Guest".localized(), text: "\(primary?.guestName ?? ""), \(primary?.gender ?? ""), \(primary?.age.intValue().oneOrMany("yr") ?? "")", subText: "\(primary?.email ?? "")\n\(primary?.contactNo ?? "")")
            var right3: MoreDetailsObj?
            let others = hotelTripDetails.hotelGuests.filter({ $0.isPrimary == 0})
            if others.count > 0 {
                var otherGuestText = ""
                for other in others {
                    otherGuestText += "\(other.guestName), \(other.gender) \(other.age.intValue().oneOrMany("yr"))\n"
                }
                right3 = MoreDetailsObj(title: "Other Guests".localized(), text: otherGuestText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let text3 = MoreDetails(leftText: left3, rightText: right3)
            
            moreDetails = [text1, text2, text3]
            
        } else if let holidayTripDetails = holidayTripDetails {
            moreDetails = [MoreDetails]()
            
            let left1 = MoreDetailsObj(title: "Start Date".localized(), text: holidayTripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "")
            let right1 = MoreDetailsObj(title: "End Date".localized(), text: holidayTripDetails.bookingTo.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "")
            let text1 = MoreDetails(leftText: left1, rightText: right1)
            
            let left2 = MoreDetailsObj(title: "Travellers".localized(), text: "\(holidayTripDetails.adultCount.oneOrMany("Adult")) & \(holidayTripDetails.childCount.oneOrMany("Child", suffix: "ren"))")
            let right2 = MoreDetailsObj(title: "Duration".localized(), text: holidayTripDetails.packagedetails[0].duration)
            let text2 = MoreDetails(leftText: left2, rightText: right2)
           
            
            let primary = holidayTripDetails.packageguest.filter({ $0.isPrimary == 1}).last
            let left3 = MoreDetailsObj(title: "Primary Guest".localized(), text: "\(primary?.guestName ?? ""), \(primary?.gender ?? ""), \(primary?.age.intValue().oneOrMany("yr") ?? "")", subText: "\(primary?.email ?? "")\n\(primary?.contactNo ?? "")")
            var right3: MoreDetailsObj?
            let others = holidayTripDetails.packageguest.filter({ $0.isPrimary == 0})
            if others.count > 0 {
                var otherGuestText = ""
                for other in others {
                    otherGuestText += "\(other.guestName), \(other.gender) \(other.age.intValue().oneOrMany("yr"))\n"
                }
                right3 = MoreDetailsObj(title: "Other Guests".localized(), text: otherGuestText.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            let text3 = MoreDetails(leftText: left3, rightText: right3)
            
            moreDetails = [text1, text2, text3]
            
        } else if let activityTripDetails = activityTripDetails {
            moreDetails = [MoreDetails()]
            
            let left1 = MoreDetailsObj(title: "Activity Date".localized(), text: activityTripDetails.bookingFrom.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "")
            let right1 = MoreDetailsObj(title: "Total Members".localized(), text: activityTripDetails.totalGuest.stringValue())
            let text1 = MoreDetails(leftText: left1, rightText: right1)
            
            let primary = activityTripDetails.activityguest[0]
            let left2 = MoreDetailsObj(title: "Primary Customer".localized(), text: "\(primary.guestName), \(primary.gender), \(primary.age.intValue().oneOrMany("yr"))", subText: "\(primary.emailID)\n\(primary.contactNo)")
            let text2 = MoreDetails(leftText: left2)
            
            moreDetails = [text1, text2]
        } else if let meetupTripDetails = meetupTripDetails {
            moreDetails = [MoreDetails()]
            
            let left1 = MoreDetailsObj(title: "Meetup Date".localized(), text: meetupTripDetails.meetupDetails.meetupDate.date("yyyy-MM-dd'T'HH:mm:ss")?.stringValue(format: "E, dd MMM yyyy") ?? "")
            let right1 = MoreDetailsObj(title: "Total Members".localized(), text: meetupTripDetails.adultCount.stringValue())
            let text1 = MoreDetails(leftText: left1, rightText: right1)
            
            let primary = meetupTripDetails.meetupGuests[0]
            let left2 = MoreDetailsObj(title: "Primary Customer".localized(), text: "\(primary.guestName), \(primary.gender), \(primary.age.intValue().oneOrMany("yr"))", subText: "\(primary.email)\n\(primary.contactNo)")
            let text2 = MoreDetails(leftText: left2)
            
            moreDetails = [text1, text2]
        }
    }
    
    func getDetailsData() -> DetailsData? {
        return detailsData
    }
    
    func getMoreDetails() -> [MoreDetails]? {
        return moreDetails
    }
    
    func getAmountDetails() -> [AmountDetail]? {
        return amountDetails
    }
}
