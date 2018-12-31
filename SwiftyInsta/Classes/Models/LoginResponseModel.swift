//
//  LoginResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct LoginResponseModel: Codable, BaseStatusResponseProtocol {
    public var status: String?
    public var loggedInUser: UserShortModel
    
    public init(status: String?, loggedInUser: UserShortModel) {
        self.status = status
        self.loggedInUser = loggedInUser
    }
}
