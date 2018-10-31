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
    private static let instagramUrl = "https://i.instagram.com"
    private static let api = "/api"
    private static let apiVersion = "/v1"
    private static let apiSuffix = api + apiVersion
    private static let baseInstagramApiUrl = instagramUrl + apiSuffix

    // Endpoints
    private static let accountCreate = "/accounts/create/"
    private static let accountLogin = "/accounts/login/"
    private static let accountTwoFactorLogin = "/accounts/two_factor_login/"
    private static let accountChangePassword = "/accounts/change_password/"
    private static let accountLogout = "/accounts/logout/"
    private static let searchUser = "/users/search"
    
    static func getInstagramUrl() throws -> URL {
        if let url = URL(string: instagramUrl) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram main url.")
    }
    
    static func getCreateAccountUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountCreate) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user creation")
    }
    
    static func getLoginUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogin) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram login url.")
    }
    
    static func getLogoutUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogout) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram logout url.")
    }
    
    static func getUserUrl(username: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, searchUser)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponent?.queryItems = [URLQueryItem(name: "q", value: username)]
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram user page.")
    }
}
