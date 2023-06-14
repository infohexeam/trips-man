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
    var cities: [City]?
    
    init(countries: [Country]) {
        self.countries = countries
    }
    
    init(cities: [City]) {
        self.cities = cities
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
    
    mutating func getCitySection(_ keyword: String = "") -> [CountrySection]? {
        if let cities = cities {
            if keyword == "" {
                sections = [CountrySection(type: .countryList, count: cities.count)]
            } else {
                sections = [CountrySection(type: .countryList, count: cities.filter({ $0.cityName.contains(keyword) }).count)]
            }
        }
        return sections
    }
    
    func getCountries(_ keyword: String = "") -> [Country]? {
        if keyword == "" {
            return countries
        } else {
            return countries?.filter( { $0.name.contains(keyword) })
        }
    }
    
    func getCities(_ keyword: String = "") -> [City]? {
        if keyword == "" {
            return cities
        } else {
            return cities?.filter( { $0.cityName.contains(keyword) })
        }
    }
}
