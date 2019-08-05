//
//  Media.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserTagsModel: Codable {
    public var `in`: [UserTagItemModel]?

    public init(tags: [UserTagItemModel]?) {
        self.in = tags
    }
}

public struct UserTagItemModel: Codable {
    public var user: User?

    public init(user: User?) {
        self.user = user
    }
}

public struct DeleteMediaResponse: Codable, StatusEnforceable {
    public var didDelete: Bool?
    public var status: String?

    public init(didDelete: Bool?, status: String?) {
        self.didDelete = didDelete
        self.status = status
    }
}
