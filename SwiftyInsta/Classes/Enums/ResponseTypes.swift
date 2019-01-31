//
//  ResponseTypes.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum ResponseTypes {
    case unknown
    case loginRequired
    case challengeRequired
    case verifyMethodRequired
    case requestLimit
    case ok
    case wrongRequest
    case internalError
    case spam
    case actionBlocked
    case temporarilyBlocked
    case fail
    case sms(obfuscatedPhoneNumber: String)
    case totp
}
