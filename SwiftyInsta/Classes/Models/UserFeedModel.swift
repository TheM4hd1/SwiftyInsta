//
//  UserFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserFeedModel: Codable, FeedProtocol {
    var autoLoadMoreEnabled: Bool?
    var moreAvailable: Bool?
    var nextMaxId: String?
    var numResults: Int?
    var totalCount: Int?
    var items: [MediaModel]?
    
    private enum CodingKeys: String, CodingKey {
        case nextMaxId = "nextMaxId"
        case items = "items"
        case numResults = "numResults"
        case moreAvailable = "moreAvailable"
        case autoLoadMoreEnabled = "autoLoadMoreEnabled"
        case totalCount = "totalCount"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(Int.self, forKey: .nextMaxId) {
            nextMaxId = String(value)
        } else {
            nextMaxId = try? container.decode(String.self, forKey: .nextMaxId)
        }

        autoLoadMoreEnabled = try? container.decode(Bool.self, forKey: .autoLoadMoreEnabled)
        moreAvailable = try? container.decode(Bool.self, forKey: .moreAvailable)
        numResults = try? container.decode(Int.self, forKey: .numResults)
        totalCount = try? container.decode(Int.self, forKey: .totalCount)
        items = try? container.decode([MediaModel].self, forKey: .items)
    }
}
