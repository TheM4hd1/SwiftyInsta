//
//  SessionStorage.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct SessionStorage: Codable {
    public var username: String
    public var password: String
    public var csrfToken: String
    public var rankToken: String
    public var loggedInUser: UserShortModel
    
    public init(username: String, password: String, csrfToken: String, rankToken: String, loggedInUser: UserShortModel) {
        self.username = username
        self.password = password
        self.csrfToken = csrfToken
        self.rankToken = rankToken
        self.loggedInUser = loggedInUser
    }
    
    /// Leave blank if you don't want to login.
    public static func create(username: String, password: String) -> SessionStorage {
        return SessionStorage(
            username: username,
            password: password,
            csrfToken: "",
            rankToken: "",
            loggedInUser: UserShortModel()
        )
    }
}
