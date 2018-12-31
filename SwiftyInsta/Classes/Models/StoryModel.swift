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

public struct StoryFeedModel: Codable, BaseStatusResponseProtocol {
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

public struct StoryReelFeedModel: Codable, BaseStatusResponseProtocol {
    //var broadcast
    public var reel: TrayModel?
    public var status: String?
    
    public init(reel: TrayModel?, status: String?) {
        self.reel = reel
        self.status = status
    }
}

public struct ConfigureStoryUploadModel: Codable {
    public var _uuid: String
    public var _uid: String
    public var _csrftoken: String
    public var source_type: String
    public var caption: String
    public var upload_id: String
    //var edits
    public var disable_comments: Bool
    public var configure_mode: Int
    public var campera_position: String
    
    public init(_uuid: String, _uid: String, _csrftoken: String, source_type: String, caption: String, upload_id: String, disable_comments: Bool, configure_mode: Int, campera_position: String) {
        self._uuid = _uuid
        self._uid = _uid
        self._csrftoken = _csrftoken
        self.source_type = source_type
        self.caption = caption
        self.upload_id = upload_id
        self.disable_comments = disable_comments
        self.configure_mode = configure_mode
        self.campera_position = campera_position
    }
}
