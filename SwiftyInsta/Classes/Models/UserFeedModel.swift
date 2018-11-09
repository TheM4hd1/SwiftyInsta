//
//  UserFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct UserFeedModel: Codable, FeedProtocol {
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var numResults: Int?
    var items: [MediaModel]?
}
