//
//  FriendshipStatusModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/31/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct FriendshipStatusModel: Codable {
    public var following: Bool?
    public var followedBy: Bool?
    public var blocking: Bool?
    public var isPrivate: Bool?
    public var incomingRequest: Bool?
    public var outgoingRequest: Bool?
    public var isBestie: Bool?
    public var muting: Bool?
    public var isMutingReel: Bool?
    
    public init(following: Bool?, followedBy: Bool?, blocking: Bool?, isPrivate: Bool?, incomingRequest: Bool?, outgoingRequest: Bool?, isBestie: Bool?, muting: Bool?, isMutingReel: Bool?) {
        self.following = following
        self.followedBy = followedBy
        self.blocking = blocking
        self.isPrivate = isPrivate
        self.incomingRequest = incomingRequest
        self.outgoingRequest = outgoingRequest
        self.isBestie = isBestie
        self.muting = muting
        self.isMutingReel = isMutingReel
    }
}

public struct FollowResponseModel: Codable, BaseStatusResponseProtocol {
    public var friendshipStatus: FriendshipStatusModel?
    public var status: String?
    
    public init(friendshipStatus: FriendshipStatusModel?, status: String?) {
        self.friendshipStatus = friendshipStatus
        self.status = status
    }
}

public struct FriendshipStatusesModel: Codable {
    public let friendshipStatuses: [String: FriendshipStatusModel]
    public let status: String
}
