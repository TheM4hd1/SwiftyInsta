//
//  ActivityResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 16/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `RecentActivity` response.
public struct RecentActivity: ParsedResponse {
    /// A `Count` response.
    public struct Count: Codable {
        /// The `commentLikes` value.
        public let commentLikes: Int
        /// The `campaignNotifications` value.
        public let campaignNotifications: Int
        /// The `likes` value.
        public let likes: Int
        /// The `comments` value.
        public let comments: Int
        /// The `usertags` value.
        public let tags: Int
        /// The `relationships` value.
        public let relationships: Int
        /// The `photosOfYou` value.
        public let photosOfYou: Int
        /// The requests.
        public let requests: Int

        /// Init with `rawResponse`.
        public init(rawResponse: DynamicResponse) {
            self.commentLikes = rawResponse.commentLikes.int ?? 0
            self.campaignNotifications = rawResponse.campaignNotifications.int ?? 0
            self.likes = rawResponse.likes.int ?? 0
            self.comments = rawResponse.comments.int ?? 0
            self.tags = rawResponse.usertags.int ?? 0
            self.relationships = rawResponse.relationships.int ?? 0
            self.photosOfYou = rawResponse.photosOfYou.int ?? 0
            self.requests = rawResponse.requests.int ?? 0
        }
    }
    /// The `Story` response.
    public struct Story: IdentifiableParsedResponse {
        /// Init with `rawResponse`.
        public init?(rawResponse: DynamicResponse) {
            guard rawResponse != .none else { return nil }
            self.rawResponse = rawResponse
        }

        /// The `rawResponse`.
        public let rawResponse: DynamicResponse

        /// The `counts` value.
        public var count: Count {
            return Count(rawResponse: rawResponse.counts)
        }
        /// The `args` value.
        public var arguments: [DynamicResponse] {
            return rawResponse.arguments.array ?? []
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

    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `counts` value.
    public var count: Count {
        return Count(rawResponse: rawResponse.counts)
    }
    /// The `aymf.items` value.
    public var suggestedUsers: [SuggestedUser] {
        return rawResponse.aymf.items.array?
            .compactMap(SuggestedUser.init)
            ?? []
    }
    /// The `friendRequestStories` value.
    public var friendRequestStories: [Story] {
        return rawResponse.friendRequestStories.array?
            .compactMap(Story.init)
            ?? []
    }
    /// The `newStories` value.
    public var newStories: [Story] {
        return rawResponse.newStories.array?
            .compactMap(Story.init)
            ?? []
    }
    /// The `oldStories` value.
    public var oldStories: [Story] {
        return rawResponse.oldStories.array?
            .compactMap(Story.init)
            ?? []
    }
    /// The `continuationToken` value.
    public var continuationToken: String? {
        return rawResponse.continuationToken.string
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
