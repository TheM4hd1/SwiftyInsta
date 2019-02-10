//
//  UserTags.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 2/10/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct UserTags: Codable {
    public let `in`: [NewTag]
    public let removed: [Int]
}

public struct NewTag: Codable {
    let user_id: Int
    let position: [Double]
}
