//
//  VideoVersionModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct VideoVersionModel: Codable, ProfilePicVersionsProtocol {
    public var height: Int?
    public var url: String?
    public var width: Int?
    public var id: String?
    public var type: Int?
    
    public init(height: Int?, url: String?, width: Int?, id: String?, type: Int?) {
        self.height = height
        self.url = url
        self.width = width
        self.id = id
        self.type = type
    }
}
