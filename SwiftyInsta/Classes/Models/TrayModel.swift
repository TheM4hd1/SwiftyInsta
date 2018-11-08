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

/*
 We need to manually decode this model.
 the reason is sometimes the 'id' is Integer and sometimes its String.
 */
struct TrayModel: Codable {
    var id: String?
    var latestReelMedia: Int?
    var expiringAt: Int?
    var seen: Double?
    var canReply: Bool?
    var canReshare: Bool?
    var reelType: String?
    var owner: UserShortModel?
    var user: UserModel?
    var items: [TrayItems]?
    var prefetchCount: Int?
    var uniqueIntegerReelId: Int?
    var rankedPosition: Int?
    var seenRankedPosition: Int?
    var sourceToken: String?
    
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
        
        latestReelMedia = try container.decodeIfPresent(Int.self, forKey: .latestReelMedia)
        expiringAt = try container.decodeIfPresent(Int.self, forKey: .expiringAt)
        seen = try container.decodeIfPresent(Double.self, forKey: .seen)
        canReply = try container.decodeIfPresent(Bool.self, forKey: .canReply)
        canReshare = try container.decodeIfPresent(Bool.self, forKey: .canReshare)
        reelType = try container.decodeIfPresent(String.self, forKey: .reelType)
        owner = try container.decodeIfPresent(UserShortModel.self, forKey: .owner)
        user = try container.decodeIfPresent(UserModel.self, forKey: .user)
        items = try container.decodeIfPresent([TrayItems].self, forKey: .items)
        prefetchCount = try container.decodeIfPresent(Int.self, forKey: .prefetchCount)
        uniqueIntegerReelId = try container.decodeIfPresent(Int.self, forKey: .uniqueIntegerReelId)
        rankedPosition = try container.decodeIfPresent(Int.self, forKey: .rankedPosition)
        seenRankedPosition = try container.decodeIfPresent(Int.self, forKey: .seenRankedPosition)
        sourceToken = try container.decodeIfPresent(String.self, forKey: .sourceToken)
        
    }
}
