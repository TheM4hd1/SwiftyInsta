//
//  ThreadResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 05/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `Thread` response.
public struct Thread: ThreadIdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `muted` value.
    public var isMuted: Bool { return rawResponse.muted.bool ?? false }
    /// The `threadTitle` value.
    public var title: String { return rawResponse.threadTitle.string ?? "" }
    /// The `isGroup` value.
    public var isGroup: Bool { return rawResponse.isGroup.bool ?? false }

    /// The `users` value.
    public var users: [User] { return rawResponse.users.array?.compactMap(User.init) ?? [] }
    /// The `messages` value.
    public var messages: [Message] { return rawResponse.items.array?.compactMap(Message.init) ?? [] }

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

/// A `Message` response.
public struct Message: ItemIdentifiableParsedResponse, UserIdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `timestamp` value.
    public var sentAt: Date {
        return rawResponse.timestamp
            .double
            .flatMap { $0 / pow(10.0, max(floor(log10($0)) - 9, 0)) }
            .flatMap { Date(timeIntervalSince1970: $0) } ?? .distantPast
    }
    /// The `text` value.
    public var text: String? {
        return rawResponse.text.string
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

/// A `Recipient` model.
public struct Recipient: ParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `user` value.
    public var user: User? { return User(rawResponse: rawResponse.user) }
    /// The `thread` value.
    public var thread: Thread? { return Thread(rawResponse: rawResponse.thread) }

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
