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
        case description
        case map
        case inclusions
        case termsAndConditions
    }
    
    struct ActivityDescription {
        var title, description: String
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
            sections = [ActivityDetailsSection(type: .image, count: activityDetails.activityImages.count),
                        ActivityDetailsSection(type: .activityDetails, count: 1),
                        ActivityDetailsSection(type: .description, count: 3),
                        ActivityDetailsSection(type: .map, count: 1),
                        ActivityDetailsSection(type: .inclusions, count: activityDetails.activityInclusion.count),
                        ActivityDetailsSection(type: .termsAndConditions, count: 1)]
        }
    }
    
    func getDescription() -> [ActivityDescription]? {
        if let activityDetails = activityDetails {
            return [ActivityDescription(title: "Overview", description: activityDetails.overview),
                    ActivityDescription(title: "Features", description: activityDetails.features),
                    ActivityDescription(title: "Highlights", description: activityDetails.highlights)]

        }
        return nil
    }
    
    func getActivityDetails() -> ActivityDetails? {
        return self.activityDetails
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
