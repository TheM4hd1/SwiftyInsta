//
//  PaginationParameters.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/3/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct PaginationParameters {
    public var maxPagesToLoad: Int = Int.max
    public var pagesLoaded: Int = 0
    public var nextId = ""
    
    private init(maxPages: Int) {
        maxPagesToLoad = maxPages
    }
    
    public static func maxPagesToLoad(maxPages: Int) -> PaginationParameters {
        return PaginationParameters(maxPages: maxPages)
    }
}
