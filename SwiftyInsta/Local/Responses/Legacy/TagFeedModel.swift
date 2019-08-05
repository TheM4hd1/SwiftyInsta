//
//  TagFeedModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/10/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct TagFeedModel: Codable, PaginationProtocol, StatusEnforceable {
    public var autoLoadMoreEnabled: Bool?
    public var moreAvailable: Bool?
    public var nextMaxId: String?
    public var numResults: Int?
    public var status: String?
    public var rankedItems: [Media]?
    public var items: [Media]?

    public init(autoLoadMoreEnabled: Bool?,
                moreAvailable: Bool?,
                nextMaxId: String?,
                numResults: Int?,
                status: String?,
                rankedItems: [Media]?,
                items: [Media]?) {
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
