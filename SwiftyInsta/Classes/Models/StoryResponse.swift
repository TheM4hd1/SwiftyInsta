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
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The actual `TrayElement`s.
    public var items: [TrayElement] {
        return rawResponse.tray.array?.compactMap { TrayElement(rawResponse: $0) } ?? []
    }
}

/// A `TrayArchive` response.
public struct TrayArchive: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `mediaCount` value.
    public var count: Int { rawResponse.mediaCount.int ?? 0 }
}

/// A `TrayElement` response.
public struct TrayElement: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `title` value.
    public var title: String? {
        rawResponse.title.string
    }
    /// The `latestReelMedia` value.
    public var updatedAt: Date {
        rawResponse.latestReelMedia
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `expiringAtDate` value.
    public var expiringAt: Date {
        rawResponse.expiringAt
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `lastSeenOnDate` value.
    public var lastSeenOn: Date {
        rawResponse.seen
            .double
            .flatMap { $0 > 9_999_999_999 ? $0/1_000 : $0 }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `containsUnseen` value.
    public var containsUnseenMedia: Bool {
        updatedAt > lastSeenOn
    }
    /// The `hasBestiesMedia` value.
    public var containsBestiesOnlyMedia: Bool {
        rawResponse.hasBestiesMedia.bool ?? false
    }
    /// The `muted` value.
    public var isMuted: Bool {
        rawResponse.muted.bool ?? false
    }

    /// The `coverMedia` value.
    public var cover: Media? {
        Media(rawResponse: rawResponse.coverMedia)
    }
    /// The `media` value.
    public var media: [Media] {
        rawResponse.items.array?.compactMap { Media(rawResponse: $0) } ?? []
    }
    /// The `user` value.
    public var user: User? {
        User(rawResponse: rawResponse.user == .none ? rawResponse.owner : rawResponse.user)
    }
}

// MARK: - Paginated
/// A `StoryViewers` response.
public struct StoryViewers: PaginatedResponse {
    /// The `rawResponse`.
    public var rawResponse: DynamicResponse

    /// Init.
    public init(rawResponse: DynamicResponse) {
        self.rawResponse = rawResponse
    }

    /// User count.
    public var users: Int { rawResponse.userCount.int ?? 0 }
    /// Total viewers count.
    public var viewers: Int { rawResponse.totalViewerCount.int ?? 0 }
}
