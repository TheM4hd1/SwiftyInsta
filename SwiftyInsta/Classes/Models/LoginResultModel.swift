//
//  LoginResultModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/25/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

enum LoginResultModel {
    case success
    case badPassword
    case invalidUser
    case twoFactorRequired
    case challengeRequired
    case exception
    case responseError
}
