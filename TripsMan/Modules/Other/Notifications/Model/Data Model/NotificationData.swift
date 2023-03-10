//
//  NotificationData.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 18/01/23.
//

import Foundation

// MARK: - NotificationResp
struct NotificationData: Codable {
    let data: [Notifications]
    let status: Int
    let message: String
}

// MARK: - NotificationData
struct Notifications: Codable {
    let id: Int
    let title, notificationText, notificationDate: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case notificationText = "notification_text"
        case notificationDate = "notification_date"
    }
}
