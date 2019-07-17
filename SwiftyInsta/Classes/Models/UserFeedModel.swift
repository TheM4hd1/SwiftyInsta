//
//  UserFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserFeedModel: Codable, FeedProtocol {
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var numResults: Int?
    public var totalCount: Int?
    public var items: [MediaModel]?
    
    private enum CodingKeys: String, CodingKey {
        case nextMaxId
        case items
        case numResults
        case moreAvailable
        case autoLoadMoreEnabled
        case totalCount
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let value = try container.decode(Int.self, forKey: .nextMaxId)
            nextMaxId = String(value)
        } catch {
            nextMaxId = try? container.decode(String.self, forKey: .nextMaxId)
        }

        autoLoadMoreEnabled = try? container.decode(Bool.self, forKey: .autoLoadMoreEnabled)
        moreAvailable = try? container.decode(Bool.self, forKey: .moreAvailable)
        numResults = try? container.decode(Int.self, forKey: .numResults)
        totalCount = try? container.decode(Int.self, forKey: .totalCount)
        items = try? container.decode([MediaModel].self, forKey: .items)
    }
}
