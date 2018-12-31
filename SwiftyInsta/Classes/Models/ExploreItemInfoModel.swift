//
//  ExploreItemInfoModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/8/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ExploreItemInfoModel: Codable {
    public var numColumns: Int?
    public var totalNumColumns: Int?
    public var aspectRatio: Int?
    public var autopaly: Bool?
    
    public init(numColumns: Int?, totalNumColumns: Int?, aspectRatio: Int?, autopaly: Bool?) {
        self.numColumns = numColumns
        self.totalNumColumns = totalNumColumns
        self.aspectRatio = aspectRatio
        self.autopaly = autopaly
    }
}
