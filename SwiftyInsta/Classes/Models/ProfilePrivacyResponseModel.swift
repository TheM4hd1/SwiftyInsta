//
//  ProfilePrivacyResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/13/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ProfilePrivacyResponseModel: Codable, BaseStatusResponseProtocol {
    public var user: UserShortModel?
    public var status: String?
    
    public init(user: UserShortModel?, status: String?) {
        self.user = user
        self.status = status
    }
}
