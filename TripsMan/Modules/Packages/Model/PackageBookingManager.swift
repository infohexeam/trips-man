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
        case header
        case primaryTraveller
        case buttons
    }
    
    class PackageBookingSection {
        let type: SectionTypes
        let count: Int
        let subItems: [PackageBookingSection]
        
        init(type: SectionTypes, count: Int, subItems: [PackageBookingSection] = []) {
            self.type = type
            self.count = count
            self.subItems = subItems
        }
        
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
            sections = [PackageBookingSection(type: .packageSummary, count: 1),
                        PackageBookingSection(type: .header, count: 1),
                        PackageBookingSection(type: .primaryTraveller, count: 1),
                        PackageBookingSection(type: .buttons, count: 1)]
        }
    }
    
    func getPackageDetails() -> PackageDetails? {
        return self.packageDetails
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
