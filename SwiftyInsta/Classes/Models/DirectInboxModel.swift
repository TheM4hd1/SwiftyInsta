//
//  DirectInboxModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/12/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct DirectInboxModel: Codable, BaseStatusResponseProtocol {
    var inbox: InboxModel
    var seqId: Int?
    var pending_requests_total: Int?
    var most_recent_inviter: UserShortModel?
    var snapshot_at_ms: Int?
    var status: String?
}

struct InboxModel: Codable {
    var threads: [InboxThreadsModel]?
    var hasOlder: Bool?
    var unseenCount: Int?
    var unseenCountTs: Int?
    var blendedInboxEnabled: Bool?
}

struct InboxThreadsModel: Codable {
    var threadId: String?
    var threadV2Id: String?
    var users: [UserModel]?
    var leftUsers: [UserModel]?
    var items: [InboxThreadsModel]?
    var lastSeenActivityAt: Int?
    var muted: Bool?
    var isPin: Bool?
    var named: Bool?
    var valuedRequest: Bool?
    var canonical: Bool?
    var pending: Bool?
    var threadType: String?
    var viewerId: Int?
    var threadTitle: String?
    var pendingScore: Int?
    var vcMuted: Bool?
    var isGroup: Bool?
    var reshareSendCount: Int?
    var reshareReceiveSendCount: Int?
    var expiringMediaSendCount: Int?
    var expiringMediaReceiveCount: Int?
    var inviter: UserShortModel?
    var hasOlder: Bool?
    var hasNewer: Bool?
    var newestCursor: String?
    var oldestCursor: String?
    var isSpam: Bool?
    var lastPermanentItem: ThreadItemModel?
}

struct ThreadItemModel: Codable {
    var itemId: String?
    var userId: Int?
    var timestamp: Int?
    var text: String?
    var clientContext: String?
    var itemType: String?
    
}

struct RavenMedia: Codable, MediaModelProtocol {
    var id: String?
    var mediaId: Int?
    var mediaType: Int?
    var imageVersions2: CandidatesModel?
    var originalWidth: Int?
    var originalHeight: Int?
    var organicTrackingToken: String?
    var caption: CaptionModel?
    var takenAt: Int?
    var pk: Int?
    var code: String?
    var clientCacheKey: String?
    var filterType: Int?
    var deviceTimestamp: Int?
}
