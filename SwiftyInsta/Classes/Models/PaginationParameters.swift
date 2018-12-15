//
//  PaginationParameters.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/3/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct PaginationParameters {
    var maxPagesToLoad: Int = Int.max
    var pagesLoaded: Int = 0
    var nextId = ""
    
    private init(maxPages: Int) {
        maxPagesToLoad = maxPages
    }
    
    static func maxPagesToLoad(maxPages: Int) -> PaginationParameters {
        return PaginationParameters(maxPages: maxPages)
    }
}
