//
//  SearchManager.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 19/05/23.
//

import Foundation

struct SearchManager {
    
    var search: Search?
    var searchResults: [SearchResult]?
    
    struct SearchResult {
        var name: String
        var type: String
    }
    
    init(search: Search?) {
        self.search = search
        setSearchResults()
    }
    
    mutating func setSearchResults() {
        if let search = search {
            searchResults = [SearchResult]()
            if let hotels = search.hotel {
                for hotel in hotels {
                    searchResults?.append(SearchResult(name: "\(hotel.hotelName), \(hotel.hotelCity ?? ""), \(hotel.hotelState ?? "")", type: hotel.hotelType))
                }
            } else if let holidays = search.holiday {
                for holiday in holidays {
                    searchResults?.append(SearchResult(name: holiday.packageName, type: holiday.countryName))
                }
            } else if let activities = search.activity {
                for activity in activities {
                    searchResults?.append(SearchResult(name: "\(activity.activityName), \(activity.activityLocation)", type: ""))
                }
            } else if let meetups = search.meetup {
                for meetup in meetups {
                    searchResults?.append(SearchResult(name: meetup.meetupName, type: ""))
                }
            }
        }
    }
    
    func getSearchResults() -> [SearchResult]? {
        return searchResults
    }
}
