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
    public enum Reference: Hashable {
        /// Through their primary key.
        case primaryKey(Int)
        /// Through their username.
        case username(String)
        /// The logged in `User`.
        case me
    }

    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

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
            .max(by: {
                ($0.width.double ?? 0) < ($1.width.double ?? 0)
                    && ($0.height.double ?? 0) < ($1.height.double ?? 0)
            })?
            .url ?? rawResponse.hdProfilePicUrlInfo.url
    }
    /// The `isPrivate` value.
    public var isPrivate: Bool { return rawResponse.isPrivate.bool ?? true }
    /// The `isVerified` value.
    public var isVerified: Bool { return rawResponse.isVerified.bool ?? false }
    /// The `friendship` value.
    public var friendship: Friendship? {
        return Friendship(rawResponse: rawResponse.friendship)
            ?? Friendship(rawResponse: rawResponse.friendshipStatus)
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

    /// The `followerCount` value.
    public var followerCount: Int? { return rawResponse.followerCount.int }
    /// The `followingCount` value.
    public var followingCount: Int? { return rawResponse.followingCount.int }
    /// The `mediaCount` value.
    public var mediaCount: Int? { return rawResponse.mediaCount.int }
    /// The `profileContext` value.
    public var profileContext: String? { return rawResponse.profileContext.string }
    /// The `profileContext` value.
    public var socialContext: String? { return rawResponse.socialContext.string }

    /// A `User.Reference`.
    public var reference: Reference {
        return identity.primaryKey.flatMap(Reference.primaryKey)
            ?? .username(username)
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

/// A `Friendship` response.
public struct Friendship: ParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

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
    public var isInYourCloseFriendsList: Bool {
        return rawResponse.isBestie.bool ?? false
    }

    /// The `isPrivate` value.
    public var isPrivate: Bool {
        return rawResponse.isPrivate.bool ?? false
    }
    /// The `isRestricted` value.
    public var isRestricted: Bool {
        return rawResponse.isRestricted.bool ?? false
    }

    /// The `incomingRequest` value.
    public var requestedToFollowYou: Bool {
        return rawResponse.incomingRequest.bool ?? false
    }
    /// The `outgoingRequest` value.
    public var followRequestSent: Bool {
        return rawResponse.outgoingRequest.bool ?? false
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
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `user` value.
    public var user: User? {
        return User(rawResponse: rawResponse.user)
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
