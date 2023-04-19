//
//  ActivityDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/04/23.
//

import Foundation

struct ActivityDetailsManager {
    enum SectionTypes {
        case image
        case activityDetails
        case seperator
        case overview
        case inclusions
        case termsAndConditions
    }
    
    struct ActivityDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [ActivityDetailsSection]? = nil
    var activityDetails: ActivityDetails?
    
    init(activityDetails: ActivityDetails) {
        self.activityDetails = activityDetails
        setSections()
    }
    
    func getSections() -> [ActivityDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let activityDetails = activityDetails {
            sections = [ActivityDetailsSection(type: .image, count: activityDetails.activityImages.count)]
        }
    }
    
    func getActivityDetails() -> ActivityDetails? {
        return self.activityDetails
    }
    
    
}
