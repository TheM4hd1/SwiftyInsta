//
//  LoginResultModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/25/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum LoginResultModel {
    case success
    case badPassword
    case invalidUser
    case twoFactorRequired
    case challengeRequired
    case badSecurityCode
    case exception
    case responseError
}
