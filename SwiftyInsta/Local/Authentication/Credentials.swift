//
//  Credentials.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 09/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A class holding reference to the `base authentication` user.
public struct Credentials {
    /// Prefered verification method.
    public enum Verification: String { case email = "1", text = "0" }
    /// Response.
    enum Response {
        case challenge(URL)
        case twoFactor(String)
        case success
        case failure
        case unknown
    }

    /// The username.
    public private(set) var username: String
    /// The password.
    var password: String
    /// The verification method.
    public var verification: Verification
    /// The code.
    public var code: String? {
        didSet {
            // notify a change.
            guard code != nil else { return }
            handler?.authentication.code(for: self)
        }
    }

    /// The code handler.
    weak var handler: APIHandler?
    /// The _csrfToken_.
    var csrfToken: String?
    /// The response model.
    var response: Response = .unknown
    /// The completion handler.
    var completionHandler: ((Result<(Authentication.Response, APIHandler), Error>) -> Void)?

    // MARK: Init
    public init(username: String,
                password: String,
                verifyBy verification: Verification) {
        self.username = username
        self.password = password
        self.verification = verification
    }
}
