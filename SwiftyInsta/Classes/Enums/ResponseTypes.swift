//
//  ResponseTypes.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

enum ResponseTypes {
    case unknown
    case loginRequired
    case requestLimit
    case ok
    case wrongRequest
    case internalError
    case spam
    case actionBlocked
    case temporarilyBlocked
    case fail
}
