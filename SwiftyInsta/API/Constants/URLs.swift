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
    
    // MARK: - Base Url
    private static let instagramUrl = "https://i.instagram.com"
    private static let api = "/api"
    private static let apiVersion = "/v1"
    private static let apiSuffix = api + apiVersion
    private static let baseInstagramApiUrl = instagramUrl + apiSuffix

    // MARK: - Endpoints
    private static let accountCreate = "/accounts/create/"
    private static let accountLogin = "/accounts/login/"
    private static let accountTwoFactorLogin = "/accounts/two_factor_login/"
    private static let accountChangePassword = "/accounts/change_password/"
    private static let accountLogout = "/accounts/logout/"
    private static let searchUser = "/users/search"
    private static let userFollowing = "/friendships/%ld/following/"
    private static let userFollowers = "/friendships/%ld/followers/"
    private static let currentUser = "/accounts/current_user?edit=true"
    private static let exploreFeed = "/discover/explore/"
    private static let userTimeLine = "/feed/timeline"
    private static let userFeed = "/feed/user/"
    
    // MARK: - Methods
    
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
    
    static func getUserFollowing(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") throws -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            throw CustomErrors.urlCreationFaild("Cant create URL for user followings.\n nil inputs.")
        }

        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userFollowing, userPk))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "rank_token", value: rankToken))
            
            if !maxId.isEmpty {
                queryItems.append(URLQueryItem(name: "max_id", value: maxId))
            }
            
            if !searchQuery.isEmpty {
                queryItems.append(URLQueryItem(name: "query", value: searchQuery))
            }
            
            urlComponent?.queryItems = queryItems
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user followings.")
    }
    
    static func getUserFollowers(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") throws -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            throw CustomErrors.urlCreationFaild("Cant create URL for user followers.\n nil inputs.")
        }
        
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userFollowers, userPk))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var queryItems: [URLQueryItem] = []
            queryItems.append(URLQueryItem(name: "rank_token", value: rankToken))
            
            if !maxId.isEmpty {
                queryItems.append(URLQueryItem(name: "max_id", value: maxId))
            }
            
            if !searchQuery.isEmpty {
                queryItems.append(URLQueryItem(name: "query", value: searchQuery))
            }
            
            urlComponent?.queryItems = queryItems
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user followers.")
    }
    
    static func getCurrentUser() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, currentUser)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for current user.")
    }
    
    static func getExploreFeedUrl(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, exploreFeed)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for exploring feed.")
    }
    
    static func getUserTimeLineUrl(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, userTimeLine)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for timeline feed.")
    }
    
    static func getUserFeedUrl(userPk: Int?, maxId: String = "") throws -> URL {
        guard let userPk = userPk else {
            throw CustomErrors.urlCreationFaild("Cant create URL for user feed.\n nil input.")
        }
        
        if let url = URL(string: String(format: "%@%@%ld", baseInstagramApiUrl, userFeed, userPk)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems?.append(URLQueryItem(name: "max_id", value: maxId))
            }
            
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user feed.")
    }
}
