//
//  NotificationBean.swift
//  SmartAttendance
//
//  Created by Aamir Shaikh on 10/24/18.
//  Copyright © 2018 Gexton. All rights reserved.
//

import Foundation

struct NotificationBean : Codable {
    var idTimeStamp : String = ""
    var title: String = ""
    var body: String = ""
    var isRead : Bool!
}
