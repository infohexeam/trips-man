//
//  RoomDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 25/05/23.
//

import Foundation


struct RoomDetailsManager {
    enum SectionTypes {
        case image
        case roomDetails
        case roomAmenities
        case popularAmenities
        case houseRules
        case priceDetails
    }
    
    struct RoomDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [RoomDetailsSection]? = nil
    var roomDetails: RoomDetails?
    
    init(roomDetails: RoomDetails) {
        self.roomDetails = roomDetails
        setSections()
    }
    
    func getSections() -> [RoomDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let roomDetails = roomDetails {
            sections = [RoomDetailsSection(type: .image, count: roomDetails.roomImage.count),
                        RoomDetailsSection(type: .roomDetails, count: 1),
                        RoomDetailsSection(type: .roomAmenities, count: roomDetails.roomFacilities.count),
                        RoomDetailsSection(type: .popularAmenities, count: roomDetails.popularAmenities.count),
                        RoomDetailsSection(type: .priceDetails, count: 1)]
            
            if roomDetails.roomImage.count == 0 {
                sections?.remove(at: 0)
            }
        }
    }
    
    func getRoomDetails() -> RoomDetails? {
        return self.roomDetails
    }
    
}
