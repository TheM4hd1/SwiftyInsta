//
//  ExploreFeedItemModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct ExploreFeedItemModel: Codable {
    var stories: StoryModel?
    var media: MediaModel?
    var exploreItemInfo: ExploreItemInfoModel?
}
