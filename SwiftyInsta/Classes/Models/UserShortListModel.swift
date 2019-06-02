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

public struct PendingFriendshipsModel: Codable, BaseStatusResponseProtocol {
    public var status: String?
    public var nextMaxId: String? = ""
    public var bigList: Bool?
    public var pageSize: Int?
    public var users: [UserShortModel]?
    //public var suggestedUsers: SuggestedUsers?
    
    public init(status: String?, nextMaxId: String? = "", bigList: Bool?, pageSize: Int?, users: [UserShortModel]?) {
        self.status = status
        self.nextMaxId = nextMaxId
        self.bigList = bigList
        self.pageSize = pageSize
        self.users = users
    }
}

public struct SuggestedUsers: Codable {
    public var suggestionCards: [SuggestionCards]?
    public var netegoType: String?
}

public struct SuggestionCards: Codable {
    public var userCard: UserCard?
}

public struct UserCard: Codable {
    public var user: UserShortModel?
    public var algorithm: String?
    public var socialContext: String?
    public var followedBy: Bool?
    public var uuid: String?
}
