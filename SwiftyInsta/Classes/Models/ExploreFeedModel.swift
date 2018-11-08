//
//  ExploreFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ExploreFeedModel: Codable, BaseStatusResponseProtocol {
    var rankToken: String?
    var autoLoadMoreEnabled: Bool?
    var nextMaxId: String?
    var maxId: String?
    var items: [ExploreFeedItemModel]?
    var numResults: Int?
    var status: String?
}
