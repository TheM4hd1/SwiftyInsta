//
//  UserShortListModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/4/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserShortListModel: Codable, BaseStatusResponseProtocol {
    public var status: String?
    public var nextMaxId: String? = ""
    public var bigList: Bool?
    public var pageSize: Int?
    public var users: [UserShortModel]?
    
    public init(status: String?, nextMaxId: String? = "", bigList: Bool?, pageSize: Int?, users: [UserShortModel]?) {
        self.status = status
        self.nextMaxId = nextMaxId
        self.bigList = bigList
        self.pageSize = pageSize
        self.users = users
    }
}
