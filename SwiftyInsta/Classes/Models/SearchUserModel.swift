//
//  SearchUserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct SearchUserModel: Codable {
    var hasMore: Bool?
    var numResults: Int?
    var users: [UserModel]?
}
