//
//  CustomErrors.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public extension Error {
    /// Returns `true` if `self` is `AuthenticationError.checkpoint` or `AuthenticationError.twoFactor`, `false` otherwise.
    var requiresInstagramCode: Bool {
        guard let error = self as? AuthenticationError else { return false }
        switch error {
        case .checkpoint, .twoFactor: return true
        default: return false
        }
    }
}

public enum AuthenticationError: Error, LocalizedError {
    case checkpoint(suggestions: [String]?)
    case checkpointLoop
    case invalidPassword
    case invalidUsername
    case twoFactor
    
    public var localizedDescription: String {
        switch self {
        case .checkpoint: return "Checkpoint required.\nThe user will receive a code shortly through their preferred verification method.\nPass it back to  `Credentials.code` and wait for the response in this same `completionHandler`."
        case .checkpointLoop: return "Checkpoint loop.\nLog in from the Instagram app and then try again."
        case .twoFactor: return "Two factor required.\nThe user will receive a code shortly through their preferred verification method.\nPass it back to  `Credentials.code` and wait for the response in this same `completionHandler`."
        case .invalidUsername: return "Invalid username."
        case .invalidPassword: return "Invalid password."
        }
    }
}

public enum CustomErrors: Error {
    case urlCreationFaild(_ description: String)
    case runTimeError(_ description: String)
    case weakReferenceReleased
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
        case .weakReferenceReleased:
            return "`weak` reference was released."
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
