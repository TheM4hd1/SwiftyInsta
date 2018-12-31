//
//  RecentRecipientsModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/12/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol RecipientProtocol {
    var expires: Int? {get}
    var filtered: Bool? {get}
    var requestId: String? {get}
    var rankToken: String? {get}
}

public struct RankedRecipientsModel: Codable, BaseStatusResponseProtocol, RecipientProtocol {
    public var rankedRecipients: [RecipientItemModel]?
    public var expires: Int?
    public var filtered: Bool?
    public var requestId: String?
    public var rankToken: String?
    public var status: String?
    
    public init(rankedRecipients: [RecipientItemModel]?, expires: Int?, filtered: Bool?, requestId: String?, rankToken: String?, status: String?) {
        self.rankedRecipients = rankedRecipients
        self.expires = expires
        self.filtered = filtered
        self.requestId = requestId
        self.rankToken = rankToken
        self.status = status
    }
}

public struct RecentRecipientsModel: Codable, BaseStatusResponseProtocol, RecipientProtocol {
    public var recentRecipients: [RecipientItemModel]?
    public var expires: Int?
    public var filtered: Bool?
    public var requestId: String?
    public var rankToken: String?
    public var status: String?
    
    public init(recentRecipients: [RecipientItemModel]?, expires: Int?, filtered: Bool?, requestId: String?, rankToken: String?, status: String?) {
        self.recentRecipients = recentRecipients
        self.expires = expires
        self.filtered = filtered
        self.requestId = requestId
        self.rankToken = rankToken
        self.status = status
    }
}

public struct RecipientItemModel: Codable {
    public var thread: InboxThreadsModel?
    public var user: UserShortModel?
    
    public init(thread: InboxThreadsModel?, user: UserShortModel?) {
        self.thread = thread
        self.user = user
    }
}
