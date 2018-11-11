//
//  RecentFollowingsActivitiesModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/11/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct RecentFollowingsActivitiesModel: Codable, BaseStatusResponseProtocol {
    var aymf: AymfItemModel?
    var counts: CountsModel?
    var friendRequestStories: [FriendRequestStoriesModel]?
    var newStories: [RecentActivityStoryModel]?
    var oldStories: [RecentActivityStoryModel]?
    var continuationToken: Int?
    var status: String?
}

struct AymfItemModel: Codable, FeedProtocol {
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var numResults: Int?
    var items: [SuggestionModel]?
}

struct CountsModel: Codable {
    var commentLikes: Int?
    var campaignNotification: Int?
    var likes: Int?
    var comments: Int?
    var usertags: Int?
    var relationships: Int?
    var photosOfYou: Int?
    var requests: Int?
}

struct FriendRequestStoriesModel: Codable {
    var type: Int?
    var args: ArgsModel?
    var counts: CountsModel?
}

struct ArgsModel: Codable {
    var text: String?
    var requestCount: Int?
    var clicked: Bool?
    var profileId: Int?
    var profileImage: String?
    var secondProfileId: Int?
    var secondProfileImage: String?
    var timestamp: Double?
    var tuuid: String?
    var profileName: String?
    var links: [ArgsLinksModel]?
}

struct ArgsLinksModel: Codable {
    var start: Int?
    var end: Int?
    var type: String?
    var id: String?
    
    private enum CodingKeys: String, CodingKey {
        case start = "start"
        case end = "end"
        case type = "type"
        case id = "id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(Int.self, forKey: .id) {
            if let value = value {
                id = String(value)
            } else {
                id = try container.decode(String.self, forKey: .id)
            }
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        start = try container.decode(Int.self, forKey: .start)
        end = try container.decode(Int.self, forKey: .end)
        type = try container.decode(String.self, forKey: .type)
    }
}

struct RecentActivityStoryModel: Codable {
    var type: Int?
    var storyType: Int?
    var args: ArgsModel?
    var counts: CountsModel?
    var pk: String?
}
