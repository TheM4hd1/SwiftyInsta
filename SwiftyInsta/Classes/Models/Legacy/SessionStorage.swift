//
//  SessionStorage.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct SessionStorage: Codable {
    enum CodingKeys: CodingKey {
        case dsUserId, data, csrfToken, sessionId, rankToken
    }

    /// The user `pk`.
    public var dsUserId: String
    /// The logged in user info.
    public var user: User?

    var csrfToken: String
    var sessionId: String
    var rankToken: String

    /// Init.
    public init(dsUserId: String,
                user: User?,
                csrfToken: String,
                sessionId: String,
                rankToken: String) {
        self.dsUserId = dsUserId
        self.user = user
        self.csrfToken = csrfToken
        self.sessionId = sessionId
        self.rankToken = rankToken
    }
    /// Decode.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dsUserId = try container.decode(String.self, forKey: .dsUserId)
        self.user = try? container.decodeIfPresent(Data.self, forKey: .data).flatMap(User.decode)
        self.csrfToken = try container.decode(String.self, forKey: .csrfToken)
        self.sessionId = try container.decode(String.self, forKey: .sessionId)
        self.rankToken = try container.decode(String.self, forKey: .rankToken)
    }
    /// Encode.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dsUserId, forKey: .dsUserId)
        try container.encode(user?.encode(), forKey: .data)
        try container.encode(csrfToken, forKey: .csrfToken)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(rankToken, forKey: .rankToken)
    }
}
