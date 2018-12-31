//
//  DirectInboxModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/12/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct DirectInboxModel: Codable, BaseStatusResponseProtocol {
    public var inbox: InboxModel
    public var seqId: Int?
    public var pending_requests_total: Int?
    public var most_recent_inviter: UserShortModel?
    public var snapshot_at_ms: Int?
    public var status: String?
    
    public init(inbox: InboxModel, seqId: Int?, pending_requests_total: Int?, most_recent_inviter: UserShortModel?, snapshot_at_ms: Int?, status: String?) {
        self.inbox = inbox
        self.seqId = seqId
        self.pending_requests_total = pending_requests_total
        self.most_recent_inviter = most_recent_inviter
        self.snapshot_at_ms = snapshot_at_ms
        self.status = status
    }
}

public struct InboxModel: Codable {
    public var threads: [InboxThreadsModel]?
    public var hasOlder: Bool?
    public var unseenCount: Int?
    public var unseenCountTs: Int?
    public var blendedInboxEnabled: Bool?
    
    public init(threads: [InboxThreadsModel]?, hasOlder: Bool?, unseenCount: Int?, unseenCountTs: Int?, blendedInboxEnabled: Bool?) {
        self.threads = threads
        self.hasOlder = hasOlder
        self.unseenCount = unseenCount
        self.unseenCountTs = unseenCountTs
        self.blendedInboxEnabled = blendedInboxEnabled
    }
}

public struct InboxThreadsModel: Codable {
    public var threadId: String?
    public var threadV2Id: String?
    public var users: [UserModel]?
    public var leftUsers: [UserModel]?
    public var items: [ThreadItemModel]?
    public var lastSeenActivityAt: Int?
    public var muted: Bool?
    public var isPin: Bool?
    public var named: Bool?
    public var valuedRequest: Bool?
    public var canonical: Bool?
    public var pending: Bool?
    public var threadType: String?
    public var viewerId: Int?
    public var threadTitle: String?
    public var pendingScore: Int?
    public var vcMuted: Bool?
    public var isGroup: Bool?
    public var reshareSendCount: Int?
    public var reshareReceiveSendCount: Int?
    public var expiringMediaSendCount: Int?
    public var expiringMediaReceiveCount: Int?
    public var inviter: UserShortModel?
    public var hasOlder: Bool?
    public var hasNewer: Bool?
    public var newestCursor: String?
    public var oldestCursor: String?
    public var isSpam: Bool?
    public var lastPermanentItem: ThreadItemModel?
    
    public init(threadId: String?, threadV2Id: String?, users: [UserModel]?, leftUsers: [UserModel]?, items: [ThreadItemModel]?, lastSeenActivityAt: Int?, muted: Bool?, isPin: Bool?, named: Bool?, valuedRequest: Bool?, canonical: Bool?, pending: Bool?, threadType: String?, viewerId: Int?, threadTitle: String?, pendingScore: Int?, vcMuted: Bool?, isGroup: Bool?, reshareSendCount: Int?, reshareReceiveSendCount: Int?, expiringMediaReceiveCount: Int?, inviter: UserShortModel?, hasOlder: Bool?, hasNewer: Bool?, newestCursor: String?, oldestCursor: String?, isSpam: Bool?, lastPermanentItem: ThreadItemModel?) {
        self.threadId = threadId
        self.threadV2Id = threadV2Id
        self.users = users
        self.leftUsers = leftUsers
        self.items = items
        self.lastSeenActivityAt = lastSeenActivityAt
        self.muted = muted
        self.isPin = isPin
        self.named = named
        self.valuedRequest = valuedRequest
        self.canonical = canonical
        self.pending = pending
        self.threadType = threadType
        self.viewerId = viewerId
        self.threadTitle = threadTitle
        self.pendingScore = pendingScore
        self.vcMuted = vcMuted
        self.isGroup = isGroup
        self.reshareReceiveSendCount = reshareReceiveSendCount
        self.expiringMediaReceiveCount = expiringMediaReceiveCount
        self.inviter = inviter
        self.hasOlder = hasOlder
        self.hasNewer = hasNewer
        self.newestCursor = newestCursor
        self.oldestCursor = oldestCursor
        self.isSpam = isSpam
        self.lastPermanentItem = lastPermanentItem
    }
}

public struct ThreadItemModel: Codable {
    public var itemId: String?
    public var userId: Int?
    public var timestamp: Int?
    public var text: String?
    public var clientContext: String?
    public var itemType: String?
    
    public init(itemId: String?, userId: Int?, timestamp: Int?, text: String?, clientContext: String?, itemType: String?) {
        self.itemId = itemId
        self.userId = userId
        self.timestamp = timestamp
        self.text = text
        self.clientContext = clientContext
        self.itemType = itemType
    }
}

public struct RavenMedia: Codable, MediaModelProtocol {
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

public struct DirectPayloadModel: Codable {
    public var clientContext: String?
    public var itemId: String?
    public var timestamp: String?
    public var threadId: String?
    
    public init(clientContext: String?, itemId: String?, timestamp: String?, threadId: String?) {
        self.clientContext = clientContext
        self.itemId = itemId
        self.timestamp = timestamp
        self.threadId = threadId
    }
}

public struct DirectSendMessageResponseModel: Codable, BaseStatusResponseProtocol {
    var status: String?
    var statusCode: String?
    var action: String?
    var payload: DirectPayloadModel
    
    public init(status: String?, statusCode: String?, action: String?, payload: DirectPayloadModel) {
        self.status = status
        self.statusCode = statusCode
        self.action = action
        self.payload = payload
    }
}

public struct ThreadModel: Codable, BaseStatusResponseProtocol {
    var thread: InboxThreadsModel?
    var status: String?
    
    public init(thread: InboxThreadsModel?, status: String?) {
        self.thread = thread
        self.status = status
    }
}
