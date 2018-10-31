//
//  LoginResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct LoginResponseModel: Codable, BaseStatusResponseProtocol {
    var status: String?
    var loggedInUser: UserShortModel
}
