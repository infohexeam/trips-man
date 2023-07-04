//
//  PackageDetailsManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 22/03/23.
//

import Foundation

struct PackageDetailsManager {
    enum SectionTypes {
        case image
        case packageDetails
        case seperator
        case vendorDetails
        case itinerary
        case policies
    }
    
    struct PackageDetailsSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [PackageDetailsSection]? = nil
    var packageDetails: PackageDetails?
    
    init(packageDetails: PackageDetails) {
        self.packageDetails = packageDetails
        setSections()
    }
    
    func getSections() -> [PackageDetailsSection]? {
        return sections
    }
    
    mutating func setSections() {
        if let packageDetails = packageDetails {
            sections = [PackageDetailsSection(type: .image, count: packageDetails.holidayImage.count),
                        PackageDetailsSection(type: .packageDetails, count: 1),
                        PackageDetailsSection(type: .seperator, count: 1),
                        PackageDetailsSection(type: .vendorDetails, count: 1),
                        PackageDetailsSection(type: .itinerary, count: packageDetails.holidayItinerary.count),
                        PackageDetailsSection(type: .policies, count: 1)]
        }
    }
    
    func getPackageDetails() -> PackageDetails? {
        return self.packageDetails
    }
    
    
}
