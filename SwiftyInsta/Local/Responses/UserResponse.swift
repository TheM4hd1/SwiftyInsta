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
    /// A quick way to reference a `User`.
    public enum Reference {
        /// Through their primary key.
        case primaryKey(Int)
        /// Through their username.
        case username(String)
        /// The logged in `User`.
        case me
    }

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
    /// The `friendship` value.
    public var friendship: Friendship? {
        rawResponse.friendship == .none ? nil : Friendship(rawResponse: rawResponse.friendship)
    }

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

/// A `Friendship` response.
public struct Friendship: ParsedResponse {
    /// Init with `rawResponse`.
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `following` value.
    public var isFollowedByYou: Bool {
        rawResponse.following.bool ?? false
    }
    /// The `followedBy` value.
    public var isFollowingYou: Bool? {
        rawResponse.followedBy.bool
    }
    /// The `blocking` value.
    public var isBlockedByYou: Bool? {
        rawResponse.blocking.bool
    }
    /// The `isBestie` value.
    public var isInYourCloseFriendsList: Bool? {
        rawResponse.isBestie.bool
    }

    /// The `incomingRequest` value.
    public var requestedToFollowYou: Bool? {
        rawResponse.incomingRequest.bool
    }
    /// The `outgoingRequest` value.
    public var followRequestSent: Bool? {
        rawResponse.outgoingRequest.bool
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
