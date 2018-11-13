//
//  MediaModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol MediaModelProtocol {
    var takenAt: Int? {get}
    var pk: Int? {get}
    var id: String? {get}
    var deviceTimestamp: Int? {get}
    var mediaType: Int? {get}
    var code: String? {get}
    var clientCacheKey: String? {get}
    var filterType: Int? {get}
    var imageVersions2: CandidatesModel? {get}
    var originalWidth: Int? {get}
    var originalHeight: Int? {get}
    var organicTrackingToken: String? {get}
    var caption: CaptionModel? {get}
}

struct ExploreInfoModel: Codable {
    var explanation: String?
    var actorId: Int?
    var sourceToken: String?
}

struct UserTagsModel: Codable {
    var `in`: [UserTagItemModel]?
}

struct UserTagItemModel: Codable {
    var user: UserShortModel?
}

struct MediaModel: Codable, MediaModelProtocol {
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
    var user: UserModel?
    var previewComments: [CommentModel]?
    var canViewMorePreviewComments: Bool?
    var commentCount: Int?
    var videoDashManifest: String?
    var videoCodec: String?
    var numberOfQualities: Int?
    var videoVersions: [VideoVersionModel]?
    var hasAudio: Bool?
    var videoDuration: Double?
    var viewCount: Double?
    var canViewerReshare: Bool?
    var caption: CaptionModel?
    var exploreHideComments: Bool?
    var algorithm: String?
    var exploreContext: String?
    var exploreSourceToken: String?
    var connectionId: String?
    var mezqlToken: String?
    var impressionToken: String?
    var explore: ExploreInfoModel?
    var location: LocationShortModel?
    var preview: String?
    var inventorySource: String?
    var likeCount: Int?
    var hasLiked: Bool?
    var usertags: UserTagsModel?
    //var topLikers: [UserShortModel]?
}
