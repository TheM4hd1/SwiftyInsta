//
//  SessionStorage.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct SessionStorage: Codable {
    var username: String
    var password: String
    var csrfToken: String
    var rankToken: String
    var loggedInUser: UserShortModel
    
    /// Leave blank if you don't want to login.
    static func create(username: String, password: String) -> SessionStorage {
        return SessionStorage(
            username: username,
            password: password,
            csrfToken: "",
            rankToken: "",
            loggedInUser: UserShortModel()
        )
    }
}
