//
//  CaptionModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct CaptionModel: Codable {
    var pk: Int?
    var userId: Int?
    var text: String
    var user: UserModel?
}
