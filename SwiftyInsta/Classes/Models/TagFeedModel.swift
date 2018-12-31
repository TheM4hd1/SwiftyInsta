//
//  TagFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct TagFeedModel: Codable, FeedProtocol, BaseStatusResponseProtocol {
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var numResults: Int?
    public var status: String?
    public var rankedItems: [MediaModel]?
    public var items: [MediaModel]?
    
    public init(autoLoadMoreEnabled: Bool?, moreAvailable: Bool?, nextMaxId: String?, numResults: Int?, status: String?, rankedItems: [MediaModel]?, items: [MediaModel]?) {
        self.autoLoadMoreEnabled = autoLoadMoreEnabled
        self.moreAvailable = moreAvailable
        self.nextMaxId = nextMaxId
        self.numResults = numResults
        self.status = status
        self.rankedItems = rankedItems
        self.items = items
    }
    //var story: TrayModel?
}
