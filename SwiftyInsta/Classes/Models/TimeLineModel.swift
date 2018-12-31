//
//  TimeLineModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/9/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct TimeLineModel: Codable, FeedProtocol, BaseStatusResponseProtocol {
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var numResults: Int?
    public var status: String?
    public var feedItems: [TimeLineItemModel]?
    public var isDirectV2Enabled: Bool?
    
    public init(autoLoadMoreEnabled: Bool?, moreAvailable: Bool?, nextMaxId: String?, numResults: Int?, status: String?, feedItems: [TimeLineItemModel]?, isDirectV2Enabled: Bool?) {
        self.autoLoadMoreEnabled = autoLoadMoreEnabled
        self.moreAvailable = moreAvailable
        self.nextMaxId = nextMaxId
        self.numResults = numResults
        self.status = status
        self.feedItems = feedItems
        self.isDirectV2Enabled = isDirectV2Enabled
    }
}

public struct SuggestionModel: Codable {
    public var user: SuggestionUser?//UserShortModel?
    public var algorithm: String?
    public var socialContext: String?
    public var uuid: String?
    
    public init(user: SuggestionUser?, algorithm: String?, socialContext: String?, uuid: String?) {
        self.user = user
        self.algorithm = algorithm
        self.socialContext = socialContext
        self.uuid = uuid
    }
}

public struct SuggestedUsersModel: Codable {
    public var type: Int?
    public var suggestions: [SuggestionModel]?
    public var id: String?
    public var trackingToken: String?
    
    public init(type: Int?, suggestions: [SuggestionModel]?, id: String?, trackingToken: String) {
        self.type = type
        self.suggestions = suggestions
        self.id = id
        self.trackingToken = trackingToken
    }
}

public struct TimeLineItemModel: Codable {
    public var mediaOrAd: MediaModel?
    public var suggestedUsers: SuggestedUsersModel?
    
    public init(mediaOrAd: MediaModel?, suggestedUsers: SuggestedUsersModel?) {
        self.mediaOrAd = mediaOrAd
        self.suggestedUsers = suggestedUsers
    }
}

public struct SuggestionUser: Codable {
    public var isVerified: Bool?
    public var isPrivate: Bool?
    public var pk: String?
    public var profilePicUrl: String?
    public var profilePicId: String?
    public var username: String?
    public var fullName: String?
    
    public init(isVerified: Bool?, isPrivate: Bool?, pk: String?, profilePicUrl: String?, profilePicId: String?, username: String?, fullName: String?) {
        self.isVerified = isVerified
        self.isPrivate = isPrivate
        self.pk = pk
        self.profilePicUrl = profilePicUrl
        self.profilePicId = profilePicId
        self.username = username
        self.fullName = fullName
    }
}
