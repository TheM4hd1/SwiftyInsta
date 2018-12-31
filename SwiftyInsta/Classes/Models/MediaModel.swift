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

public struct ExploreInfoModel: Codable {
    public var explanation: String?
    public var actorId: Int?
    public var sourceToken: String?
    
    public init(explanation: String?, actorId: Int?, sourceToken: String?) {
        self.explanation = explanation
        self.actorId = actorId
        self.sourceToken = sourceToken
    }
}

public struct UserTagsModel: Codable {
    public var `in`: [UserTagItemModel]?
    
    public init(tags: [UserTagItemModel]?) {
        self.in = tags
    }
}

public struct UserTagItemModel: Codable {
    public var user: UserShortModel?
    
    public init(user: UserShortModel?) {
        self.user = user
    }
}

public struct CarouselMedia: Codable {
    public var id: String?
    public var mediaType: Int?
    public var imageVersions2: CandidatesModel?
    public var originalWidth: Int?
    public var originalHeight: Int?
    public var pk: Int?
    public var carouselParentId: String?
    
    public init(id: String?, mediaType: Int?, imageVersions2: CandidatesModel?, originalWidth: Int?, originalHeight: Int?, pk: Int?, carouselParentId: String?) {
        self.id = id
        self.imageVersions2 = imageVersions2
        self.mediaType = mediaType
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
        self.pk = pk
        self.carouselParentId = carouselParentId
    }
}

public struct MediaModel: Codable, MediaModelProtocol {
    public var takenAt: Int?
    public var pk: Int?
    public var id: String?
    public var deviceTimestamp: Int?
    public var mediaType: Int?
    public var code: String?
    public var clientCacheKey: String?
    public var filterType: Int?
    public var carouselMedia: [CarouselMedia]?
    public var imageVersions2: CandidatesModel?
    public var originalWidth: Int?
    public var originalHeight: Int?
    public var organicTrackingToken: String?
    public var user: UserModel?
    public var previewComments: [CommentModel]?
    public var canViewMorePreviewComments: Bool?
    public var commentCount: Int?
    public var videoDashManifest: String?
    public var videoCodec: String?
    public var numberOfQualities: Int?
    public var videoVersions: [VideoVersionModel]?
    public var hasAudio: Bool?
    public var videoDuration: Double?
    public var viewCount: Double?
    public var canViewerReshare: Bool?
    public var caption: CaptionModel?
    public var exploreHideComments: Bool?
    public var algorithm: String?
    public var exploreContext: String?
    public var exploreSourceToken: String?
    public var connectionId: String?
    public var mezqlToken: String?
    public var impressionToken: String?
    public var explore: ExploreInfoModel?
    public var location: LocationShortModel?
    public var preview: String?
    public var inventorySource: String?
    public var likeCount: Int?
    public var hasLiked: Bool?
    public var usertags: UserTagsModel?
    //var topLikers: [UserShortModel]?
    
    public init(takenAt: Int?, pk: Int?, id: String?, deviceTimestamp: Int?, mediaType: Int?, code: String?, clientCacheKey: String?, filterType: Int?, carouselMedia: [CarouselMedia]?, imageVersions2: CandidatesModel?, originalWidth: Int?, originalHeight: Int?, organicTrackingToken: String?, user: UserModel?, previewComments: [CommentModel]?, canViewMorePreviewComments: Bool?, commentCount: Int?, videoDashManifest: String?, videoCodec: String?, numberOfQualities: Int?, videoVersions: [VideoVersionModel]?, hasAudio: Bool?, videoDuration: Double?, viewCount: Double?, canViewerReshare: Bool?, caption: CaptionModel?, exploreHideComments: Bool?, algorithm: String?, exploreContext: String?, exploreSourceToken: String?, connectionId: String?, mezqlToken: String?, impressionToken: String?, explore: ExploreInfoModel?, location: LocationShortModel?, preview: String?, inventorySource: String?, likeCount: Int?, hasLiked: Bool?, usertags: UserTagsModel?) {
        self.takenAt = takenAt
        self.pk = pk
        self.id = id
        self.deviceTimestamp = deviceTimestamp
        self.mediaType = mediaType
        self.code = code
        self.clientCacheKey = clientCacheKey
        self.filterType = filterType
        self.carouselMedia = carouselMedia
        self.imageVersions2 = imageVersions2
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
        self.organicTrackingToken = organicTrackingToken
        self.user = user
        self.previewComments = previewComments
        self.canViewMorePreviewComments = canViewMorePreviewComments
        self.commentCount = commentCount
        self.videoDashManifest = videoDashManifest
        self.videoCodec = videoCodec
        self.numberOfQualities = numberOfQualities
        self.videoVersions = videoVersions
        self.hasAudio = hasAudio
        self.videoDuration = videoDuration
        self.viewCount = viewCount
        self.canViewerReshare = canViewerReshare
        self.caption = caption
        self.exploreHideComments = exploreHideComments
        self.algorithm = algorithm
        self.exploreContext = exploreContext
        self.exploreSourceToken = exploreSourceToken
        self.connectionId = connectionId
        self.mezqlToken = mezqlToken
        self.impressionToken = impressionToken
        self.explore = explore
        self.location = location
        self.preview = preview
        self.inventorySource = inventorySource
        self.likeCount = likeCount
        self.hasLiked = hasLiked
        self.usertags = usertags
    }
}

public struct DeleteMediaResponse: Codable, BaseStatusResponseProtocol {
    public var did_delete: Bool?
    public var status: String?
    
    public init(did_delete: Bool?, status: String?) {
        self.did_delete = did_delete
        self.status = status
    }
}
