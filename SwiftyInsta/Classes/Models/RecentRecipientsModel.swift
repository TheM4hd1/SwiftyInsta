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

struct RankedRecipientsModel: Codable, BaseStatusResponseProtocol, RecipientProtocol {
    var rankedRecipients: [RecipientItemModel]?
    var expires: Int?
    var filtered: Bool?
    var requestId: String?
    var rankToken: String?
    var status: String?
}

struct RecentRecipientsModel: Codable, BaseStatusResponseProtocol, RecipientProtocol {
    var recentRecipients: [RecipientItemModel]?
    var expires: Int?
    var filtered: Bool?
    var requestId: String?
    var rankToken: String?
    var status: String?
}

struct RecipientItemModel: Codable {
    var thread: InboxThreadsModel?
    var user: UserShortModel?
}
