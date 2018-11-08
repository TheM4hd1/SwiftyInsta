//
//  TrayModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct TrayItems: Codable, MediaModelProtocol {
    var takenAt: Int?
    var pk: Int?
    var id: String?
    var deviceTimestamp: Int?
    var mediaType: Int?
    var code: String?
    var clientCacheKey: String?
    var filterType: Int?
    var imageVersions2: CandidatesModel?
    var originalWidth: Int?
    var originalHeight: Int?
    var organicTrackingToken: String?
    var user: UserShortModel?
    var caption: CaptionModel?
    var captionIsEdited: Bool?
    var photoOfYou: Bool?
    var canViewerSave: Bool?
    var expiringAt: Int?
    var storyLocation: LocationModel?
    var supportsReelReactions: Bool?
}

struct CandidatesModel: Codable {
    var candidates: [ProfilePicVersionsModel]?
}

struct TrayModel: Codable {
    var id: String?
    var latestReelMedia: Int?
    var expiringAt: Int?
    var seen: String?
    var canReply: Bool?
    var canReshare: Bool?
    var reelType: String?
    var owner: UserShortModel?
    var items: [TrayItems]?
    var prefetchCount: Int?
    var uniqueIntegerReelId: Int?
    var rankedPosition: Int?
}
