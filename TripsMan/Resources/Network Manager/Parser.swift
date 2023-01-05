//
//  Parser.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 27/10/22.
//

import Foundation
import Alamofire

struct Parser {
    func sendRequest<T: Decodable>(url: String, http: Alamofire.HTTPMethod, parameters: [String: Any]?, comp: @escaping (T?, AFError?) -> Void) {
        
        if NetworkReachabilityManager()!.isReachable  {
            let fullUrl = baseURLAuth + url
            AF.request(fullUrl,
                       method: http,
                       parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: T.self) { (response) in
                DispatchQueue.main.async {
                    debugPrint(response)
                    guard let data = response.value else {
                        comp(nil, response.error)
                        return
                    }
                    comp(data, nil)
                }
            }
        }
    }
    
    func sendRequestLoggedIn<T: Decodable>(url: String, http: Alamofire.HTTPMethod, parameters: [String: Any]?, comp: @escaping (T?, AFError?) -> Void) {
        
        if NetworkReachabilityManager()!.isReachable  {
            let fullUrl = baseURL + url
            let header: HTTPHeaders = ["Authorization": "Bearer \(SessionManager.shared.getLoginDetails()?.token ?? "")"]
            AF.request(fullUrl,
                       method: http,
                       parameters: parameters, encoding: JSONEncoding.default, headers: header).responseDecodable(of: T.self) { (response) in
                DispatchQueue.main.async {
                    print(fullUrl)
                    print(parameters)
                    debugPrint(response)
                    guard let data = response.value else {
                        comp(nil, response.error)
                        return
                    }
                    comp(data, nil)
                }
            }
        }
    }
    
    
    
}
