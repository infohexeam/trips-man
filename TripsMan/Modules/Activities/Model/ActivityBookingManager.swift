//
//  ActivityBookingManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/04/23.
//

import Foundation

struct ActivityBookingManager {
    enum SectionTypes {
        case summary
        case header
        case customerDetails
        case action
    }

    
    struct ActivityBookingSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [ActivityBookingSection]? = nil
    var activityDetails: ActivityDetails?
    
    init(activityDetails: ActivityDetails) {
        self.activityDetails = activityDetails
        setSections()
    }
    
    func getSections() -> [ActivityBookingSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let activityDetails = activityDetails {
            sections = [ActivityBookingSection(type: .summary, count: 1),
                        ActivityBookingSection(type: .header, count: 1),
                        ActivityBookingSection(type: .customerDetails, count: 1),
                        ActivityBookingSection(type: .action, count: 1)]
        }
    }
    
    func getActivityDetails() -> ActivityDetails? {
        return self.activityDetails
    }
}
