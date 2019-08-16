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
    public var username: String { return rawResponse.username.string ?? "" }
    /// The `fullName` value.
    public var name: String? { return rawResponse.fullName.string }
    /// The `biography` value.
    public var biography: String? { return rawResponse.biography.string }
    /// The `profilePicURL` value.
    public var thumbnail: URL? { return rawResponse.profilePicUrl.url }
    /// The `hdProfillePicVersion` value.
    public var avatar: URL? {
        return rawResponse.hdProfilePicVersions
            .array?
            .first?
            .url
    }
    /// The `isPrivate` value.
    public var isPrivate: Bool { return rawResponse.isPrivate.bool ?? true }
    /// The `isVerified` value.
    public var isVerified: Bool { return rawResponse.isVerified.bool ?? false }
    /// The `friendship` value.
    public var friendship: Friendship? {
        return rawResponse.friendship == .none
            ? nil
            : Friendship(rawResponse: rawResponse.friendship)
    }

    /// The `phoneNumber` value.
    public var phoneNumber: String? { return rawResponse.phoneNumber.string }
    /// The `email` value.
    public var email: String? { return rawResponse.emaill.string }
    /// The `externalUrl` value.
    public var website: URL? { return rawResponse.externalUrl.url }
    /// The `byline` value.
    public var byline: String? { return rawResponse.byline.string }
    /// The `isBusiness` value.
    public var isBusiness: Bool? { return rawResponse.isBusiness.bool }

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
        return rawResponse.following.bool ?? false
    }
    /// The `followedBy` value.
    public var isFollowingYou: Bool? {
        return rawResponse.followedBy.bool
    }
    /// The `blocking` value.
    public var isBlockedByYou: Bool? {
        return rawResponse.blocking.bool
    }
    /// The `isBestie` value.
    public var isInYourCloseFriendsList: Bool? {
        return rawResponse.isBestie.bool
    }

    /// The `incomingRequest` value.
    public var requestedToFollowYou: Bool? {
        return rawResponse.incomingRequest.bool
    }
    /// The `outgoingRequest` value.
    public var followRequestSent: Bool? {
        return rawResponse.outgoingRequest.bool
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

/// A `SuggestedUser` response.
public struct SuggestedUser: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `user` value.
    public var user: User? {
        return rawResponse.user == .none
            ? nil
            : User(rawResponse: rawResponse.user)
    }
    /// The `algorithm` value.
    public var algorithm: String? {
        return rawResponse.algorithm.string
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
