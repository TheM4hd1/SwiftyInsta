//
//  CustomErrors.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum CustomErrors: Error {
    case urlCreationFaild(_ description: String)
    case runTimeError(_ description: String)
    case invalidCredentials
    case twoFactorAuthentication
    case invalidTwoFactorCode
    case missingTwoFactorCode
    case challengeRequired
    case unExpected(_ description: String)
    case groupedError(_ description: String)
    case noError
}

extension CustomErrors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .urlCreationFaild(let description):
            return description
        case .runTimeError(let description):
            return description
        case .invalidCredentials:
            return "Invalid Credentials."
        case .unExpected(let description):
            return description
        case .groupedError(let description):
            return description
        case .invalidTwoFactorCode:
            return "This code is no longer valid, please request a new one"
        case .twoFactorAuthentication:
            return "Two Factor Authentication is required"
        case .challengeRequired:
            return "Challenge is required"
        case .missingTwoFactorCode:
            return "Sms validation code missing"
        default:
            return ""
        }
    }
}
