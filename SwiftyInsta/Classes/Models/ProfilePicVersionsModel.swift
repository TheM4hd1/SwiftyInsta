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

public struct ProfilePicVersionsModel: Codable, ProfilePicVersionsProtocol {
    public var height: Int?
    public var url: String?
    public var width: Int?
    
    public init(height: Int?, url: String?, width: Int?) {
        self.height = height
        self.url = url
        self.width = width
    }
}
