//
//  MediaLikersModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 1/19/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct MediaLikersModel: Codable, BaseStatusResponseProtocol {
    public var users: [UserShortModel]?
    public var userCount: Int?
    public var status: String?
    
    public init(users: [UserShortModel]?, userCount: Int?, status: String?) {
        self.users = users
        self.userCount = userCount
        self.status = status
    }
}
