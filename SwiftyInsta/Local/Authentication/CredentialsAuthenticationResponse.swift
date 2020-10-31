//
//  LoginResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct CredentialsAuthenticationResponse: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `user` value.
    public var user: User? {
        return User(rawResponse: rawResponse.loggedInUser)
    }
    /// The `status` value.
    public var status: String? {
        return rawResponse.status.string
    }
    /// The `message` value.
    public var message: String? {
        return rawResponse.message.string
    }
    /// If `true` then **two step verification**` requires.
    public var twoFactorRequired: Bool? {
        return rawResponse.twoFactorRequired.bool
    }
    /// The `checkpoint` url value.
    public var challenge: ChallengeInfo? {
        return ChallengeInfo(rawResponse: rawResponse.challenge)
    }
    /// The `twoFactorInfo` value.
    public var twoFactorInfo: TwoFactorInfo? {
        return TwoFactorInfo(rawResponse: rawResponse.twoFactorInfo)
    }
    /// The `invalidCredentials` value.
    public var invalidCredentials: Bool? {
        return rawResponse.invalidCredentials.bool
    }
    /// The `errorType` value.
    ///
    /// `bad_password`,
    /// `invalid_user`,
    /// `sms_code_validation_code_invalid`,
    /// `checkpoint_challenge_required`
    /// `rate_limit_error`
    public var errorType: String? {
        return rawResponse.errorType.string
    }

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
}

struct TwoFactorInfo: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
    /// The `username` value.
    public var username: String? {
        return rawResponse.username.string
    }
    /// If `true`, then code sends via **sms**
    public var smsOn: Bool? {
        return rawResponse.smsTwoFactorOn.bool
    }
    /// If `true`, then code needs to generate from a third-party two factor app
    public var totpTwoFactorOn: Bool? {
        return rawResponse.totpTwoFactorOn.bool
    }
    /// Last 4-digits of phone number
    public var obfuscatedPhoneNumber: String? {
        return rawResponse.obfuscatedPhoneNumber.string
    }
    /// two factor identifier
    public var identifier: String? {
        return rawResponse.twoFactorIdentifier.string
    }
    /// Remaining sms count
    public var maxSmsCount: Int? {
        return rawResponse.phoneVerificationSettings.maxSmsCount.int
    }
}

struct ChallengeInfo: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
    /// The challenge `url` value.
    public var url: String? {
        return rawResponse["url"].string
    }
    /// The `apiPath` value.
    public var apiPath: String? {
        return rawResponse.apiPath.string
    }
    /// The `challengeContext` value
    public var context: String? {
        return rawResponse.challengeContext.string
    }
}
