//
//  URLs.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// Private Instagram API
struct URLs {
    // Base Url
    static let InstagramUrl = "https://i.instagram.com"
    static let API = "/api"
    static let APIVersion = "/v1"
    static let APISuffix = API + APIVersion
    static let BaseInstagramApiUrl = InstagramUrl + APISuffix

    // Endpoints
    static let AccountCreate = "/accounts/create/"
    static let AccountLogin = "/accounts/login/";
    static let AccountTwoFactorLogin = "/accounts/two_factor_login/";
    static let AccountChangePassword = "/accounts/change_password/"
    static let AccountLogout = "/accounts/logout/";
    
    static func getInstagramUrl() throws -> URL {
        if let url = URL(string: InstagramUrl) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram main url.")
    }
    
    static func getCreateAccountUrl() throws -> URL {
        if let url = URL(string: BaseInstagramApiUrl + AccountCreate) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user creation")
    }
    
    static func getLoginUrl() throws -> URL {
        if let url = URL(string: BaseInstagramApiUrl + AccountLogin) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram login url.")
    }
}
