//
//  PackageBookingManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 24/03/23.
//

import Foundation

struct PackageBookingManager {
    enum SectionTypes {
        case packageSummary
    }
    
    struct PackageBookingSection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [PackageBookingSection]? = nil
    var packageDetails: PackageDetails?
    
    init(packageDetails: PackageDetails) {
        self.packageDetails = packageDetails
        setSections()
    }
    
    func getSections() -> [PackageBookingSection]? {
        return sections
    }
    
    mutating func setSections() {
        if packageDetails != nil {
            sections = [PackageBookingSection(type: .packageSummary, count: 1)]
        }
    }
    
    func getPackageDetails() -> PackageDetails? {
        return self.packageDetails
    }
}
