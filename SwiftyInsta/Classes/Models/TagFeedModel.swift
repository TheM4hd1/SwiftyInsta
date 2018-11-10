//
//  TagFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct TagFeedModel: Codable, FeedProtocol, BaseStatusResponseProtocol {
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var numResults: Int?
    var status: String?
    var rankedItems: [MediaModel]?
    var items: [MediaModel]?
    //var story: TrayModel?
}
