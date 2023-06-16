//
//  MeetupBookingManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 09/05/23.
//

import Foundation

struct MeetupBookingManager {
    enum SectionTypes {
        case summary
        case header
        case customerDetails
        case action
    }

    
    struct MeetupBookingSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [MeetupBookingSection]? = nil
    var meetupDetails: MeetupDetails?
    
    init(meetupDetails: MeetupDetails) {
        self.meetupDetails = meetupDetails
        setSections()
    }
    
    func getSections() -> [MeetupBookingSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let meetupDetails = meetupDetails {
            sections = [MeetupBookingSection(type: .summary, count: 1),
                        MeetupBookingSection(type: .header, count: 1),
                        MeetupBookingSection(type: .customerDetails, count: 1),
                        MeetupBookingSection(type: .action, count: 1)]
        }
    }
    
    func getMeetupDetails() -> MeetupDetails? {
        return self.meetupDetails
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
}
