//
//  StoryModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct StoryModel: Codable {
    var id: Int?
    var topLive: TopLiveModel?
    var isPortrait: Bool?
    var tray: [TrayModel]?
}

struct TopLiveModel: Codable {
    var broadcastOwners: [UserShortModel]?
    var rankedPosition: Int?
}
