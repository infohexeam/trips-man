//
//  CountryManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 21/03/23.
//

import Foundation

struct CountryManager {
    enum SectionTypes {
        case countryList
    }
    
    struct CountrySection {
        var type: SectionTypes
        var count: Int
    }
    
    var sections: [CountrySection]? = nil
    var countries: [Country]?
    
    init(countries: [Country]) {
        self.countries = countries
    }
    
    mutating func getSections(_ keyword: String = "") -> [CountrySection]? {
        setSections(keyword)
        return sections
    }
    
    mutating func setSections(_ keyword: String = "") {
        if let countries = countries {
            if keyword == "" {
                sections = [CountrySection(type: .countryList, count: countries.count)]
            } else {
                sections = [CountrySection(type: .countryList, count: countries.filter({ $0.name.contains(keyword) }).count)]
            }
            
        }
    }
    
    func getCountries(_ keyword: String = "") -> [Country]? {
        if keyword == "" {
            return countries
        } else {
            return countries?.filter( { $0.name.contains(keyword) })
        }
    }
}
