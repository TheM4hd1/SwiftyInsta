//
//  RecentFollowingsActivitiesModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/11/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct RecentActivitiesModel: Codable, BaseStatusResponseProtocol {
    public var aymf: AymfItemModel?
    public var counts: CountsModel?
    public var friendRequestStories: [RecentActivityStoryModel]?
    public var newStories: [RecentActivityStoryModel]?
    public var oldStories: [RecentActivityStoryModel]?
    public var continuationToken: Int?
    public var status: String?
    
    public init(aymf: AymfItemModel?, counts: CountsModel?, friendRequestStories: [RecentActivityStoryModel]?, newStories: [RecentActivityStoryModel]?, oldStories: [RecentActivityStoryModel]?, continuationToken: Int?, status: String?) {
        self.aymf = aymf
        self.counts = counts
        self.friendRequestStories = friendRequestStories
        self.newStories = newStories
        self.oldStories = oldStories
        self.continuationToken = continuationToken
        self.status = status
    }
}

public struct RecentFollowingsActivitiesModel: Codable, BaseStatusResponseProtocol {
    public var autoLoadMoreEnabled: Bool?
    public var nextMaxId: Int?
    public var status: String?
    public var stories: [RecentActivityStoryModel]?
    
    public init(autoLoadMoreEnabled: Bool?, nextMaxId: Int?, status: String?, stories: [RecentActivityStoryModel]?) {
        self.autoLoadMoreEnabled = autoLoadMoreEnabled
        self.nextMaxId = nextMaxId
        self.status = status
        self.stories = stories
    }
}

public struct AymfItemModel: Codable, FeedProtocol {
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var numResults: Int?
    public var items: [SuggestionModel]?
    
    public init(autoLoadMoreEnabled: Bool?, moreAvailable: Bool?, nextMaxId: String?, numResults: Int?, items: [SuggestionModel]?) {
        self.autoLoadMoreEnabled = autoLoadMoreEnabled
        self.moreAvailable = moreAvailable
        self.nextMaxId = nextMaxId
        self.numResults = numResults
        self.items = items
    }
}

public struct CountsModel: Codable {
    public var commentLikes: Int?
    public var campaignNotification: Int?
    public var likes: Int?
    public var comments: Int?
    public var usertags: Int?
    public var relationships: Int?
    public var photosOfYou: Int?
    public var requests: Int?
    
    public init(commentLikes: Int?, campaignNotification: Int?, likes: Int?, comments: Int?, usertags: Int?, relationships: Int?, photosOfYou: Int?, requests: Int?) {
        self.commentLikes = commentLikes
        self.campaignNotification = campaignNotification
        self.likes = likes
        self.comments = comments
        self.usertags = usertags
        self.relationships = relationships
        self.photosOfYou = photosOfYou
        self.requests = requests
    }
}

public struct ArgsModel: Codable {
    public var text: String?
    public var requestCount: Int?
    public var clicked: Bool?
    public var profileId: Int?
    public var profileImage: String?
    public var secondProfileId: Int?
    public var secondProfileImage: String?
    public var timestamp: Double?
    public var tuuid: String?
    public var profileName: String?
    public var links: [ArgsLinksModel]?
    
    public init(text: String?, requestCount: Int?, clicked: Bool?, profileId: Int?, profileImage: String?, secondProfileId: Int?, secondProfileImage: String?, timestamp: Double?, tuuid: String?, profileName: String?, links: [ArgsLinksModel]?) {
        self.text = text
        self.requestCount = requestCount
        self.clicked = clicked
        self.profileId = profileId
        self.profileImage = profileImage
        self.secondProfileId = secondProfileId
        self.secondProfileImage = secondProfileImage
        self.timestamp = timestamp
        self.tuuid = tuuid
        self.profileName = profileName
        self.links = links
    }
}

public struct ArgsLinksModel: Codable {
    public var start: Int?
    public var end: Int?
    public var type: String?
    public var id: String?
    
    private enum CodingKeys: String, CodingKey {
        case start = "start"
        case end = "end"
        case type = "type"
        case id = "id"
    }
    
    public init(from decoder: Decoder) throws {
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

public struct RecentActivityStoryModel: Codable {
    public var type: Int?
    public var storyType: Int?
    public var args: ArgsModel?
    public var counts: CountsModel?
    public var pk: String?
    
    public init(type: Int?, storyType: Int?, args: ArgsModel?, counts: CountsModel?, pk: String?) {
        self.type = type
        self.storyType = storyType
        self.args = args
        self.counts = counts
        self.pk = pk
    }
}
