//
//  ResultInfo.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ResultInfo {
    public var error: Error
    public var message: String
    public var responseType: ResponseTypes
    
    public init(error: Error, message: String, responseType: ResponseTypes) {
        self.error = error
        self.message = message
        self.responseType = responseType
    }
}
