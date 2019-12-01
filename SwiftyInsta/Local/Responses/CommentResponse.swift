//
//  CommentResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 05/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `Comment` response.
public struct Comment: IdentifiableParsedResponse, UserIdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `text` value.
    public var text: String { return rawResponse.text.string ?? "" }
    /// The `commentLikeCount` value.
    public var likes: Int { return rawResponse.commentLikeCount.int ?? 0 }
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
/// A `MediaComments` response.
public struct MediaComments: PaginatedResponse {
    /// The `rawResponse`.
    public var rawResponse: DynamicResponse

    /// Init.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `caption` value.
    public var caption: Comment? { return Comment(rawResponse: rawResponse.caption) }
    /// The `commentCount` value.
    public var comments: Int { return rawResponse.commentCount.int ?? 0 }
    /// The `previewComments` value.
    public var previews: [Comment] { return rawResponse.previewComments.array?.compactMap(Comment.init) ?? [] }

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
