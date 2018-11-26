//
//  StoryModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct StoryModel: Codable {
    var id: Int?
    var topLive: TopLiveModel?
    var isPortrait: Bool?
    var tray: [TrayModel]?
}

struct TopLiveModel: Codable {
    var broadcastOwners: [UserShortModel]?
    var rankedPosition: Int?
}

struct StoryFeedModel: Codable, BaseStatusResponseProtocol {
    var tray: [TrayModel]?
    var storyRankingToken: String?
    var faceFilterNuxVersion: Int?
    var hasNewNuxStory: Bool?
    var status: String?
    //var postLive
    //var broadcasts
}

struct StoryReelFeedModel: Codable, BaseStatusResponseProtocol {
    //var broadcast
    var reel: TrayModel?
    var status: String?
}
