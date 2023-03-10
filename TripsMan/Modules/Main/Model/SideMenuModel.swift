//
//  SideMenuModel.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/12/22.
//

import Foundation
import UIKit

struct SideMenuItems: Codable {
    var imageName: String
    var imageType: ImageType
    var title: String
    var titleColor: String?
    var menuSubText: String?
    var action: MenuAction
    var identifier: String?
    var index: Int?
    
}

enum MenuAction: Codable {
    case pushToVC
    case presentVC
    case switchTab
    case logout
}

enum ImageType: Codable {
    case systemImg
    case savedImg
}
