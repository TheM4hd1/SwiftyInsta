//
//  LocationModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct LocationModel: Codable {
    var x: Double?
    var y: Double?
    var z: Double?
    var width: Double?
    var height: Double?
    var rotation: Double?
    var isPinned: Double?
    var isHidden: Int?
    var location: UserShortModel?
}
