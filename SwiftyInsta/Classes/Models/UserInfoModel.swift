//
//  UserInfoModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/13/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct UserInfoModel: Codable, BaseStatusResponseProtocol {
    var user: UserModel?
    var status: String?
}
