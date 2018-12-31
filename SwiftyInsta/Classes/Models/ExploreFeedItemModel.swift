//
//  ExploreFeedItemModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ExploreFeedItemModel: Codable {
    public var stories: StoryModel?
    public var media: MediaModel?
    public var exploreItemInfo: ExploreItemInfoModel?
    
    public init(stories: StoryModel?, media: MediaModel?, exploreItemInfo: ExploreItemInfoModel?) {
        self.stories = stories
        self.media = media
        self.exploreItemInfo = exploreItemInfo
    }
}
