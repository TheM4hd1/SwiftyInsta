//
//  UserInfoModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/13/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct UserInfoModel: Codable, BaseStatusResponseProtocol {
    public var user: UserModel?
    public var status: String?
    
    public init(user: UserModel?, status: String?) {
        self.user = user
        self.status = status
    }
}
