//
//  SearchUserModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct SearchUserModel: Codable {
    public var hasMore: Bool?
    public var numResults: Int?
    public var users: [UserModel]?
    
    public init(hasMore: Bool?, numResults: Int?, users: [UserModel]?) {
        self.hasMore = hasMore
        self.numResults = numResults
        self.users = users
    }
}
