//
//  UserResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 08/02/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `User` response.
public struct User: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `username` value.
    public var username: String { rawResponse.username.string ?? "" }
    /// The `fullName` value.
    public var name: String? { rawResponse.fullName.string }
    /// The `biography` value.
    public var biography: String? { rawResponse.biography.string }
    /// The `profilePicURL` value.
    public var thumbnail: URL? { rawResponse.profilePicUrl.url }
    /// The `hdProfillePicVersion` value.
    public var avatar: URL? {
        rawResponse.hdProfilePicVersions
            .array?
            .first?
            .url
    }
    /// The `isPrivate` value.
    public var isPrivate: Bool { rawResponse.isPrivate.bool ?? true }
    /// The `isVerified` value.
    public var isVerified: Bool { rawResponse.isVerified.bool ?? false }

    /// The `phoneNumber` value.
    public var phoneNumber: String? { rawResponse.phoneNumber.string }
    /// The `email` value.
    public var email: String? { rawResponse.emaill.string }
    /// The `externalUrl` value.
    public var website: URL? { rawResponse.externalUrl.url }
    /// The `byline` value.
    public var byline: String? { rawResponse.byline.string }
    /// The `isBusiness` value.
    public var isBusiness: Bool? { rawResponse.isBusiness.bool }
}
