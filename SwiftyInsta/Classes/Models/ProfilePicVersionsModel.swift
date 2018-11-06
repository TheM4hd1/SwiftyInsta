//
//  ProfilePicVersionsModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/6/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol ProfilePicVersionsProtocol {
    var height: Int? {get}
    var url: String? {get}
    var width: Int? {get}
}

struct ProfilePicVersionsModel: Codable, ProfilePicVersionsProtocol {
    var height: Int?
    var url: String?
    var width: Int?
}
