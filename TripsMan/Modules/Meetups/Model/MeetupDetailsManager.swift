//
//  MeetupDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 08/05/23.
//

import Foundation

struct MeetupDetailsManager {
    enum SectionTypes {
        case image
        case meetupDetails
        case seperator
        case description
        case map
        case termsAndConditions
    }
    
    struct MeetupDescription {
        var title, description: String
    }
    
    struct MeetupDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [MeetupDetailsSection]? = nil
    var meetupDetails: MeetupDetails?
    
    init(meetupDetails: MeetupDetails) {
        self.meetupDetails = meetupDetails
        setSections()
    }
    
    func getSections() -> [MeetupDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let meetupDetails = meetupDetails {
            sections = [MeetupDetailsSection(type: .image, count: meetupDetails.meetupImages.count),
                        MeetupDetailsSection(type: .meetupDetails, count: 1),
                        MeetupDetailsSection(type: .description, count: getDescription()?.count ?? 0),
                        MeetupDetailsSection(type: .map, count: 1),
                        MeetupDetailsSection(type: .termsAndConditions, count: 1)]
        }
    }
    
    func getDescription() -> [MeetupDescription]? {
        if let meetupDetails = meetupDetails {
            return [MeetupDescription(title: "Overview", description: meetupDetails.shortDescription),
                    MeetupDescription(title: "Description", description: meetupDetails.details)]

        }
        return nil
    }
    
    func getMeetupDetails() -> MeetupDetails? {
        return self.meetupDetails
    }
    
    
}
