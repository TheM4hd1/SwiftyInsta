//
//  TrayModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct TrayItems: Codable, MediaModelProtocol {
    public var takenAt: Int?
    public var pk: Int?
    public var id: String?
    public var deviceTimestamp: Int?
    public var mediaType: Int?
    public var code: String?
    public var clientCacheKey: String?
    public var filterType: Int?
    public var imageVersions2: CandidatesModel?
    public var originalWidth: Int?
    public var originalHeight: Int?
    public var organicTrackingToken: String?
    public var user: UserShortModel?
    public var caption: CaptionModel?
    public var captionIsEdited: Bool?
    public var photoOfYou: Bool?
    public var canViewerSave: Bool?
    public var expiringAt: Int?
    public var storyLocation: LocationModel?
    public var supportsReelReactions: Bool?
    
    public init(takenAt: Int?, pk: Int?, id: String?, deviceTimestamp: Int?, mediaType: Int?, code: String?, clientCacheKey: String?, filterType: Int?, imageVersions2: CandidatesModel?, originalWidth: Int?, originalHeight: Int?, organicTrackingToken: String?, user: UserShortModel?, caption: CaptionModel?, captionIsEdited: Bool?, photoOfYou: Bool?, canViewerSave: Bool?, expiringAt: Int?, storyLocation: LocationModel?, supportsReelReactions: Bool?) {
        self.takenAt = takenAt
        self.pk = pk
        self.id = id
        self.deviceTimestamp = deviceTimestamp
        self.mediaType = mediaType
        self.code = code
        self.clientCacheKey = clientCacheKey
        self.filterType = filterType
        self.imageVersions2 = imageVersions2
        self.originalWidth = originalWidth
        self.originalHeight = originalHeight
        self.organicTrackingToken = organicTrackingToken
        self.user = user
        self.caption = caption
        self.captionIsEdited = captionIsEdited
        self.photoOfYou = photoOfYou
        self.canViewerSave = canViewerSave
        self.expiringAt = expiringAt
        self.storyLocation = storyLocation
        self.supportsReelReactions = supportsReelReactions
    }
}

public struct CandidatesModel: Codable {
    var candidates: [ProfilePicVersionsModel]?
    
    public init(candidates: [ProfilePicVersionsModel]?) {
        self.candidates = candidates
    }
}

/*
 We need to manually decode this model.
 the reason is sometimes the 'id' is Integer and sometimes its String.
 */
public struct TrayModel: Codable {
    public var id: String?
    public var latestReelMedia: Int?
    public var expiringAt: Int?
    public var seen: Double?
    public var canReply: Bool?
    public var canReshare: Bool?
    public var reelType: String?
    public var owner: OwnerModel?//UserShortModel?
    public var user: UserModel?
    public var items: [TrayItems]?
    public var prefetchCount: Int?
    public var uniqueIntegerReelId: Int?
    public var rankedPosition: Int?
    public var seenRankedPosition: Int?
    public var sourceToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case latestReelMedia = "latest_reel_media"
        case expiringAt = "expiring_at"
        case seen = "seen"
        case canReply = "can_reply"
        case canReshare = "can_reshare"
        case reelType = "reel_type"
        case owner = "owner"
        case user = "user"
        case items = "items"
        case prefetchCount = "prefetch_count"
        case uniqueIntegerReelId = "unique_integer_reel_id"
        case rankedPosition = "ranked_position"
        case seenRankedPosition = "seen_ranked_position"
        case sourceToken = "source_token"
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
        
        latestReelMedia = try container.decodeIfPresent(Int.self, forKey: .latestReelMedia)
        expiringAt = try container.decodeIfPresent(Int.self, forKey: .expiringAt)
        seen = try container.decodeIfPresent(Double.self, forKey: .seen)
        canReply = try container.decodeIfPresent(Bool.self, forKey: .canReply)
        canReshare = try container.decodeIfPresent(Bool.self, forKey: .canReshare)
        reelType = try container.decodeIfPresent(String.self, forKey: .reelType)
        owner = try container.decodeIfPresent(OwnerModel.self, forKey: .owner)
        user = try container.decodeIfPresent(UserModel.self, forKey: .user)
        items = try container.decodeIfPresent([TrayItems].self, forKey: .items)
        prefetchCount = try container.decodeIfPresent(Int.self, forKey: .prefetchCount)
        uniqueIntegerReelId = try container.decodeIfPresent(Int.self, forKey: .uniqueIntegerReelId)
        rankedPosition = try container.decodeIfPresent(Int.self, forKey: .rankedPosition)
        seenRankedPosition = try container.decodeIfPresent(Int.self, forKey: .seenRankedPosition)
        sourceToken = try container.decodeIfPresent(String.self, forKey: .sourceToken)
        
    }
}

public struct OwnerModel: Codable {
    public var type: String?
    public var pk: String?
    public var profilePicUrl: String?
    public var profilePicUsername: String?
    
    private enum CodingKeys: String, CodingKey {
        case type = "type"
        case pk = "pk"
        case profilePicUrl = "profile_pic_url"
        case profilePicUsername = "profile_pic_username"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decodeIfPresent(Int.self, forKey: .pk) {
            if value != nil {
                pk = String(value!)
            } else {
                pk = try container.decode(String.self, forKey: .pk)
            }
        } else {
            pk = try container.decode(String.self, forKey: .pk)
        }
        
        type = try container.decodeIfPresent(String.self, forKey: .type)
        profilePicUrl = try container.decodeIfPresent(String.self, forKey: .profilePicUrl)
        profilePicUsername = try container.decodeIfPresent(String.self, forKey: .profilePicUsername)
    }
}
