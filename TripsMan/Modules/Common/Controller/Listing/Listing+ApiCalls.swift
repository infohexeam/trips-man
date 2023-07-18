//
//  Listing+ApiCalls.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 07/06/23.
//

import Foundation

//MARK: - APICalls
extension ListingViewController {
    func getFilters() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHoteFilterlList?Language=\(SessionManager.shared.getLanguage().code)", http: .get, parameters: nil) { (result: FilterResp?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.filters = result!.data.filtes!
                        self.sorts = result!.data.sortby
                        self.tripTypes = result!.data.tripTypes!
                        self.setupMenus()
                        self.getBanners()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getPackageFilters() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerHoliday/GetCustomerHolidayFilterlList?Language=\(SessionManager.shared.getLanguage().code)", http: .get, parameters: nil) { (result: FilterResp?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.filters = result!.data.filters!
                        self.sorts = result!.data.sortby
                        self.setupMenus()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getActivityFilters() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerActivity/GetCustomerActivityFilterlList?Language=\(SessionManager.shared.getLanguage().code)", http: .get, parameters: nil) { (result: FilterResp?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.filters = result!.data.filters!
                        self.sorts = result!.data.sortby
                        self.setupMenus()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getMeetupFilters() {
        showIndicator()
        parser.sendRequestWithStaticKey(url: "api/CustomerMeetup//GetCustomerMeetupFilterlList?Language=\(SessionManager.shared.getLanguage().code)", http: .get, parameters: nil) { (result: FilterResp?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.filters = result!.data.filters!
                        self.sorts = result!.data.sortby
                        self.setupMenus()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getHotels(isPagination: Bool = false) {
        
        if !isPagination {
            currentOffset = 0
        }
        
        showIndicator()
        var params: [String: Any] = ["offset": currentOffset*recordCount,
                                     "recordCount": recordCount,
                                     "CheckInDate": hotelFilters.checkin!.stringValue(format: "yyyy/MM/dd"),
                                     "CheckOutDate": hotelFilters.checkout!.stringValue(format: "yyyy/MM/dd"),
                                     "AdultCount": hotelFilters.adult!,
                                     "ChildCount": hotelFilters.child!,
                                     "RoomCount": hotelFilters.roomCount!,
                                     "Country": SessionManager.shared.getCountry().countryCode,
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage().code,
                                     "HotelRateFrom": hotelFilters.rate!.from,
                                     "HotelRateTo": hotelFilters.rate!.to,
                                     "HotelFilters": hotelFilters.filters ?? [String: [Any]](),
                                     "SortBy": ""]
        
        if let sort = hotelFilters.sort {
            params["SortBy"] = sort.name
        }
        
        if let tripType = hotelFilters.tripType {
            params["tripType"] = tripType.id
        }
        
        if let location = hotelFilters.location {
            params["latitude"] = location.latitude
            params["longitude"] = location.longitude
        }
        
        self.isLoading = true
        parser.sendRequestWithStaticKey(url: "api/CustomerHotel/GetCustomerHotelList", http: .post, parameters: params) { (result: HotelData?, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignHotels(hotels: result!.data, offset: self.currentOffset)
                        self.hotelCollectionView.reloadData()
                        if self.filters.count == 0 {
                            self.getFilters()
                        }
                        self.currentOffset += 1
                        self.totalPages = result!.totalRecords.pageCount(with: self.recordCount)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    
    func getPackages(isPagination: Bool = false) {
        if !isPagination {
            currentOffset = 0
        }
        showIndicator()
        var params: [String: Any] = [
                                     "sortBy": "",
                                     "offset": currentOffset*recordCount,
                                     "recordCount": recordCount,
                                     "countryName": packageFilter.country?.code ?? "",
                                     "Country": SessionManager.shared.getCountry().countryCode,
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage().code,
                                     "minimumBudget": packageFilter.rate!.from,
                                     "maximumBudget": packageFilter.rate!.to,
                                     "holidayFilters": packageFilter.filters ?? [String: [Any]](),
                                     "adultCount": packageFilter.adult!,
                                     "childCount": packageFilter.child!]
        
        if let sort = packageFilter.sort {
            params["sortBy"] = sort.name
        }
        
        if let startDate = packageFilter.startDate {
            params["packageDate"] = startDate.stringValue(format: "yyyy-MM-dd")
        }
        self.isLoading = true
        parser.sendRequestWithStaticKey(url: "api/CustomerHoliday/GetCustomerHolidayPackageList", http: .post, parameters: params) { (result: PackageListingData?, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignPackages(packages: result!.data)
                        self.hotelCollectionView.reloadData()
                        if self.filters.count == 0 {
                            self.getPackageFilters()
                        }
                        self.currentOffset += 1
                        self.totalPages = result!.totalRecords.pageCount(with: self.recordCount)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getActivities(isPagination: Bool = false) {
        if !isPagination {
            currentOffset = 0
        }
        showIndicator()
        var params: [String: Any] = [
                                     "sortBy": "",
                                     "offset": currentOffset*recordCount,
                                     "recordCount": recordCount,
                                     "activityCountry": activityFilter.country?.code ?? 0,
                                     "Country": SessionManager.shared.getCountry().countryCode,
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage().code,
                                     "budgetFrom": activityFilter.rate!.from,
                                     "budgetTo": activityFilter.rate!.to,
                                     "activityFilters": activityFilter.filters ?? [String: [Any]]()]
        
        if let sort = activityFilter.sort {
            params["sortBy"] = sort.name
        }
        
        if let activityDate = activityFilter.activityDate {
            params["date"] = activityDate.stringValue(format: "yyyy-MM-dd")
        }
        self.isLoading = true
        parser.sendRequestWithStaticKey(url: "api/CustomerActivity/GetCustomerActivityList", http: .post, parameters: params) { (result: ActivityListingData?, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignActivities(activities: result!.data)
                        self.hotelCollectionView.reloadData()
                        if self.filters.count == 0 {
                            self.getActivityFilters()
                        }
                        self.currentOffset += 1
                        self.totalPages = result!.totalRecords.pageCount(with: self.recordCount)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
                
            }
        }
    }
    
    func getMeetups(isPagination: Bool = false) {
        if !isPagination {
            currentOffset = 0
        }
        showIndicator()
        var params: [String: Any] = [
                                     "sortBy": "",
                                     "offset": currentOffset*recordCount,
                                     "recordCount": recordCount,
                                     "MeetupCountry": meetupFilter.country?.code ?? 0,
                                     "Country": SessionManager.shared.getCountry().countryCode,
                                     "Currency": SessionManager.shared.getCurrency(),
                                     "Language": SessionManager.shared.getLanguage().code,
                                     "budgetFrom": meetupFilter.rate!.from,
                                     "budgetTo": meetupFilter.rate!.to,
                                     "meetupFilters": meetupFilter.filters ?? [String: [Any]]()]
        
        if let sort = meetupFilter.sort {
            params["sortBy"] = sort.name
        }
        
        
        self.isLoading = true
        parser.sendRequestWithStaticKey(url: "api/CustomerMeetup/GetCustomerMeetupList", http: .post, parameters: params) { (result: MeetupListingData?, error) in
            DispatchQueue.main.async {
                self.isLoading = false
                self.refreshControl.endRefreshing()
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignMeetups(meetups: result!.data)
                        self.hotelCollectionView.reloadData()
                        if self.filters.count == 0 {
                            self.getMeetupFilters()
                        }
                        self.currentOffset += 1
                        self.totalPages = result!.totalRecords.pageCount(with: self.recordCount)
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    
    func getBanners() {
        showIndicator()
        
        parser.sendRequestWithStaticKey(url: "api/CustomerBanner/GetCustomerBannerList?Type=hotel_list", http: .get, parameters: nil) { (result: BannerData?, error) in
            DispatchQueue.main.async {
                self.hideIndicator()
                if error == nil {
                    if result!.status == 1 {
                        self.listingManager.assignBanners(banners: result!.data)
                        self.hotelCollectionView.reloadData()
                    } else {
                        self.view.makeToast(result!.message)
                    }
                } else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
}
