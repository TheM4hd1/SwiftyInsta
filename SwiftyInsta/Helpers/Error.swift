//
//  Error.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// `Error` accessories.
public extension Error {
    /// Returns `true` if `self` is `AuthenticationError.checkpoint` or
    /// `AuthenticationError.twoFactor`, `false` otherwise.
    var requiresInstagramCode: Bool {
        switch self as? AuthenticationError {
        case .checkpoint?, .twoFactor?: return true
        default: return false
        }
    }
}

/// An `Error` specific to the login process.
public enum AuthenticationError: LocalizedError {
    /// Wrong password.
    case invalidPassword
    /// No matching username found.
    case invalidUsername
    /// Invalid code.
    case invalidCode
    /// Code sent.
    case codeSent
    /// Invalid `Authentication.Response`.
    case invalidCache

    /// Hit a checkpoint. `suggestions` might be populated with obfuscated emaill and/or phone number.
    case checkpoint(suggestions: [String]?)
    /// You keep hitting checkpoints. Log in from the **Instagram** app.
    case checkpointLoop
    /// Two factor authentication step required.
    case twoFactor

    /// The error description.
    public var errorDescription: String? {
        switch self {
        case .checkpoint:
            return """
                Checkpoint required.
                The user will receive a code shortly through their preferred verification method.
                Pass it back to  `Credentials.code` and wait for the response in this same `completionHandler`.
            """
        case .checkpointLoop: return "Checkpoint loop.\nLog in from the Instagram app and then try again."
        case .twoFactor:
            return """
                Two factor authentication required.
                The user will receive a code shortly through their preferred verification method.
                Pass it back to  `Credentials.code` and wait for the response in this same `completionHandler`.
            """
        case .invalidUsername: return "Invalid username."
        case .invalidPassword: return "Invalid password."
        case .invalidCode: return "Invalid code. Try again."
        case .codeSent: return "Verification code has been sent."
        case .invalidCache: return "Invalid `Authentication.Response`. Log out and log in again."
        }
    }
}

/// A generic `Error`.
public enum GenericError: LocalizedError {
    /// Invalid endpoint.
    case invalidEndpoint(String)
    /// Couldn''t create the `URL`.
    case invalidUrl
    /// The object was released.
    case weakObjectReleased

    /// Custom `Error` with `description`.
    case custom(_ description: String)
    /// Unknown error.
    case unknown

    /// The error description.
    public var errorDescription: String? {
        switch self {
        case .invalidEndpoint(let endpoint):
            return "Invalid \(endpoint) `URL`.\nPlease write an `Issue` on **GitHub.com** telling us what went wrong."
        case .invalidUrl:
            return "Invalid `URL`.\nPlease write an `Issue` on **GitHub.com** telling us what went wrong."
        case .weakObjectReleased:
            return "`weak` referenced Object was released."
        case .custom(let description):
            return description
        case .unknown:
            return "Unknown error."
        }
    }
}
