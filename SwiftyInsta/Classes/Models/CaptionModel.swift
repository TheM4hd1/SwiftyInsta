//
//  CaptionModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct CaptionModel: Codable {
    public var pk: Int?
    public var userId: Int?
    public var text: String
    public var user: UserModel?
    
    public init(pk: Int?, userId: Int?, text: String, user: UserModel?) {
        self.pk = pk
        self.userId = userId
        self.text = text
        self.user = user
    }
}
