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
        case facilities
        case priceDetails
    }
    
    struct RoomDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [RoomDetailsSection]? = nil
    var roomDetails: HotelRoom?
    
    init(roomDetails: HotelRoom) {
        self.roomDetails = roomDetails
        setSections()
    }
    
    func getSections() -> [RoomDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let roomDetails = roomDetails {
            sections = [RoomDetailsSection(type: .image, count: roomDetails.roomImages?.count ?? 0),
                        RoomDetailsSection(type: .roomDetails, count: 1),
                        RoomDetailsSection(type: .facilities, count: 1),
                        RoomDetailsSection(type: .priceDetails, count: 1)]
        }
    }
    
    func getRoomDetails() -> HotelRoom? {
        return self.roomDetails
    }
    
}
