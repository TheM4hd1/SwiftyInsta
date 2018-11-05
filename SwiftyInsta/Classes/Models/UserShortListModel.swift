//
//  UserShortListModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/4/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct UserShortListModel: Codable, BaseStatusResponseProtocol {
    var status: String?
    var nextMaxId: String? = ""
    var bigList: Bool?
    var pageSize: Int?
    var users: [UserShortModel]?
}
