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
    public init(rawResponse: DynamicResponse) { self.rawResponse = rawResponse }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse

    /// The `text` value.
    public var text: String { rawResponse.text.string ?? "" }
    /// The `commentLikeCount` value.
    public var likes: Int { rawResponse.commentLikeCount.int ?? 0 }
    /// The `user` value.
    public var user: User? {
        User(rawResponse: rawResponse.user == .none ? rawResponse.owner : rawResponse.user)
    }
}

// MARK: - Paginated
/// A `MediaComments` response.
public struct MediaComments: PaginatedResponse {
    /// The `rawResponse`.
    public var rawResponse: DynamicResponse

    /// Init.
    public init(rawResponse: DynamicResponse) {
        self.rawResponse = rawResponse
    }

    /// The `caption` value.
    public var caption: Comment? { Comment(rawResponse: rawResponse.caption) }
    /// The `commentCount` value.
    public var comments: Int { rawResponse.commentCount.int ?? 0 }
    /// The `previewComments` value.
    public var previews: [Comment] { rawResponse.previewComments.array?.map { Comment(rawResponse: $0) } ?? [] }
}
