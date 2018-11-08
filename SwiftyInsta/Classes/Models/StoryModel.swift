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
    var isPortrait: Bool?
    var tray: [TrayModel]?
}
