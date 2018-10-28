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
    
    private init() {}
    
    // Base Url
    private static let InstagramUrl = "https://i.instagram.com"
    private static let API = "/api"
    private static let APIVersion = "/v1"
    private static let APISuffix = API + APIVersion
    private static let BaseInstagramApiUrl = InstagramUrl + APISuffix

    // Endpoints
    private static let AccountCreate = "/accounts/create/"
    private static let AccountLogin = "/accounts/login/";
    private static let AccountTwoFactorLogin = "/accounts/two_factor_login/";
    private static let AccountChangePassword = "/accounts/change_password/"
    private static let AccountLogout = "/accounts/logout/";
    
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
