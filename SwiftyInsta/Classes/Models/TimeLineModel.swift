//
//  TimeLineModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/9/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct TimeLineModel: Codable, FeedProtocol, BaseStatusResponseProtocol {
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var numResults: Int?
    var status: String?
    var feedItems: [TimeLineItemModel]?
    var isDirectV2Enabled: Bool?
}

struct SuggestionModel: Codable {
    var user: SuggestionUser?//UserShortModel?
    var algorithm: String?
    var socialContext: String?
    var uuid: String?
}

struct SuggestedUsersModel: Codable {
    var type: Int?
    var suggestions: [SuggestionModel]?
    var id: String?
    var trackingToken: String?
}

struct TimeLineItemModel: Codable {
    var mediaOrAd: MediaModel?
    var suggestedUsers: SuggestedUsersModel?
}

struct SuggestionUser: Codable {
    var isVerified: Bool?
    var isPrivate: Bool?
    var pk: String?
    var profilePicUrl: String?
    var profilePicId: String?
    var username: String?
    var fullName: String?
}
