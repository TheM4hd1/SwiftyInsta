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
}
