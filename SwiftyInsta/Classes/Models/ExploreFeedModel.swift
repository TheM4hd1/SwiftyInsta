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
    public var rankToken: String?
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var maxId: String?
    public var items: [ExploreFeedItemModel]?
    public var numResults: Int?
    public var status: String?
    
    public init(rankToken: String?, autoLoadMoreEnabled: Bool?, moreAvailable: Bool?, nextMaxId: String?, maxId: String?, items: [ExploreFeedItemModel]?, numResults: Int?, status: String) {
        self.rankToken = rankToken
        self.autoLoadMoreEnabled = autoLoadMoreEnabled
        self.moreAvailable = moreAvailable
        self.nextMaxId = nextMaxId
        self.maxId = maxId
        self.items = items
        self.numResults = numResults
        self.status = status
    }
}
