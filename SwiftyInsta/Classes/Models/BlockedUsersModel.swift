//
//  BlockedUserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 5/28/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct BlockedUsersModel: Codable {
    public let blockedList: [BlockedUser]
    public let pageSize: Int
    public let status: String
}

public struct BlockedUser: Codable {
    public let userId: Int
    public let username: String
    public let fullName: String
    public let profilePicUrl: String
    public let blockAt: Int
}
