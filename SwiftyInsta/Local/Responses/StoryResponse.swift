//
//  StoryResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 08/02/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `Tray` response.
public struct Tray: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The actual `TrayElement`s.
    public var items: [TrayElement] {
        return rawResponse.tray.array?.compactMap { TrayElement(rawResponse: $0) } ?? []
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

/// A `TrayArchive` response.
public struct TrayArchive: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `mediaCount` value.
    public var count: Int { return rawResponse.mediaCount.int ?? 0 }

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

/// A `TrayElement` response.
public struct TrayElement: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `title` value.
    public var title: String? {
        return rawResponse.title.string
    }
    /// The `latestReelMedia` value.
    public var updatedAt: Date {
        return rawResponse.latestReelMedia
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `expiringAtDate` value.
    public var expiringAt: Date {
        return rawResponse.expiringAt
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `lastSeenOnDate` value.
    public var lastSeenOn: Date {
        return rawResponse.seen
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `containsUnseen` value.
    public var containsUnseenMedia: Bool {
        return updatedAt > lastSeenOn
    }
    /// The `hasBestiesMedia` value.
    public var containsBestiesOnlyMedia: Bool {
        return rawResponse.hasBestiesMedia.bool ?? false
    }
    /// The `muted` value.
    public var isMuted: Bool {
        return rawResponse.muted.bool ?? false
    }

    /// The `coverMedia` value.
    public var cover: Cover? {
        return Cover(rawResponse: rawResponse.coverMedia)
    }
    /// The `media` value.
    public var media: [Media] {
        return rawResponse.items.array?.compactMap { Media(rawResponse: $0) } ?? []
    }
    /// The `user` value.
    public var user: User? {
        return User(rawResponse: rawResponse.user) ?? User(rawResponse: rawResponse.owner)
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

// MARK: - Paginated
/// A `StoryViewers` response.
public struct StoryViewers: PaginatedResponse {
    /// The `rawResponse`.
    public var rawResponse: DynamicResponse

    /// Init.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// User count.
    public var users: Int { return rawResponse.userCount.int ?? 0 }
    /// Total viewers count.
    public var viewers: Int { return rawResponse.totalViewerCount.int ?? 0 }

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
