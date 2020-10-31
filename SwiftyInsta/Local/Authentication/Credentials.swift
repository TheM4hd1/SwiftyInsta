//
//  Credentials.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 09/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A class holding reference to the `base authentication` user.
public class Credentials {
    /// Prefered verification method.
    public enum Verification: String { case email = "1", text = "0" }
    /// Specifiy type of verification code.
    public enum VerificationCodeType: String { case challenge = "0", sms = "1", backup = "2", totp = "3" }
    /// Response.
    enum Response {
        case challenge(ChallengeInfo)
        case challengeForm(ChallengeForm)
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
    /// The `verification code`
    ///
    /// If the `code` is type of `twoFactor`, you need to specify it `(sms, backup, totp)`,
    /// Otherwise pass it as `challenge` and it will use the `default verification method (email, text)`
    public var code: (VerificationCodeType, String)? {
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

    /// resends `twoFactor` code
    public func resendCode(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard case .twoFactor(let identifier) = response else { return }
        handler?.authentication.resend(user: self, identifier: identifier, completionHandler: completionHandler)
    }
}
