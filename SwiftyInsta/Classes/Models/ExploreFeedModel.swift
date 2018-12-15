//
//  ExploreFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol FeedProtocol {
    var autoLoadMoreEnabled: Bool? {get}
    var moreAvailable: Bool? {get}
    var nextMaxId: String? {get}
    var numResults: Int? {get}
}

public struct ExploreFeedModel: Codable, FeedProtocol, BaseStatusResponseProtocol {
    var rankToken: String?
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var maxId: String?
    var items: [ExploreFeedItemModel]?
    var numResults: Int?
    var status: String?
}
