//
//  StoryModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct StoryModel: Codable {
    public var id: Int?
    public var topLive: TopLiveModel?
    public var isPortrait: Bool?
    public var tray: [TrayModel]?

    public init(id: Int?, topLive: TopLiveModel?, isPortrait: Bool?, tray: [TrayModel]?) {
        self.id = id
        self.topLive = topLive
        self.isPortrait = isPortrait
        self.tray = tray
    }
}

public struct TopLiveModel: Codable {
    public var broadcastOwners: [UserShortModel]?
    public var rankedPosition: Int?

    public init(broadcastOwners: [UserShortModel]?, rankedPosition: Int?) {
        self.broadcastOwners = broadcastOwners
        self.rankedPosition = rankedPosition
    }
}

public struct StoryFeedModel: Codable, StatusEnforceable {
    public var tray: [TrayModel]?
    public var storyRankingToken: String?
    public var faceFilterNuxVersion: Int?
    public var hasNewNuxStory: Bool?
    public var status: String?
    //var postLive
    //var broadcasts

    public init(tray: [TrayModel]?, storyRankingToken: String?, faceFilterNuxVersion: Int?, hasNewNuxStory: Bool?, status: String?) {
        self.tray = tray
        self.storyRankingToken = storyRankingToken
        self.faceFilterNuxVersion = faceFilterNuxVersion
        self.hasNewNuxStory = hasNewNuxStory
        self.status = status
    }
}

public struct StoryReelFeedModel: Codable, StatusEnforceable {
    //var broadcast
    public var reel: TrayModel?
    public var status: String?

    public init(reel: TrayModel?, status: String?) {
        self.reel = reel
        self.status = status
    }
}

public struct StoryReelsFeedModel: Codable, StatusEnforceable {
    public var reels: [String: TrayModel]?
    public var status: String?
}

public struct StoryArchiveFeedModel: Codable, StatusEnforceable {
    public var moreAvailable: Bool?
    public var numResults: Int?
    public var items: [StoryArchiveModel]?
    public var status: String?

    public init(moreAvailable: Bool?, numResults: Int?, items: [StoryArchiveModel]?) {
        self.moreAvailable = moreAvailable
        self.numResults = numResults
        self.items = items
    }
}

public struct StoryArchiveModel: Codable {
    public var id: String?
    public var mediaCount: Int?

    public init(id: String?, mediaCount: Int?) {
        self.id = id
        self.mediaCount = mediaCount
    }
}

public struct ConfigureStoryUploadModel: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case sourceType, caption, uploadId, disableComments, configureMode, cameraPosition
    }

    public var uuid: String
    public var uid: String
    public var csrfToken: String
    public var sourceType: String
    public var caption: String
    public var uploadId: String
    //var edits
    public var disableComments: Bool
    public var configureMode: Int
    public var cameraPosition: String

    public init(uuid: String,
                uid: String,
                csrfToken: String,
                sourceType: String,
                caption: String,
                uploadId: String,
                disableComments: Bool,
                configureMode: Int,
                cameraPosition: String) {
        self.uuid = uuid
        self.uid = uid
        self.csrfToken = csrfToken
        self.sourceType = sourceType
        self.caption = caption
        self.uploadId = uploadId
        self.disableComments = disableComments
        self.configureMode = configureMode
        self.cameraPosition = cameraPosition
    }
}

public struct StoryViewers: Codable, StatusEnforceable, PaginationProtocol {
    public var users: [UserModel]?
    public var nextMaxId: String?
    //public var updatedMedia: MediaModel?
    public var userCount: Int?
    public var totalViewerCount: Int?
    public var status: String?
}

public struct StoryHighlights: Codable {
    public var tray: [TrayModel]
    public var showEmptyState: Bool
    public var status: String
}

public struct SeenStory: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid = "_uuid", uid = "_uid", csrfToken = "_csrftoken"
        case containerModule, reels, reelMediaSkipped, liveVods, liveVodsSkipped, nuxes, nuxesSkipped
    }

    let uuid: String
    let uid: String
    let csrfToken: String
    let containerModule: String
    let reels: [String: [String]]
    let reelMediaSkipped: [String: String]
    let liveVods: [String: String]
    let liveVodsSkipped: [String: String]
    let nuxes: [String: String]
    let nuxesSkipped: [String: String]
}
