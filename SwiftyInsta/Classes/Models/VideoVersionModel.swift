//
//  VideoVersionModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct VideoVersionModel: Codable, ProfilePicVersionsProtocol {
    var height: Int?
    var url: String?
    var width: Int?
    var id: Int?
    var type: Int?
}
