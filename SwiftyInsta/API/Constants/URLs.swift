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
    private static let mediaInfo = "/media/%@/info/"
    private static let tagFeed = "/feed/tag/%@"
    private static let recentActivities = "/news/inbox/"
    private static let recentFollowingActivities = "/news/"
    private static let directInbox = "/direct_v2/inbox/"
    private static let directSendMessage = "/direct_v2/threads/broadcast/text/"
    private static let directThread = "/direct_v2/threads/%@"
    private static let recentRecipients = "/direct_share/recent_recipients/"
    private static let rankedRecipients = "/direct_v2/ranked_recipients"
    private static let setAccountPublic = "/accounts/set_public/"
    private static let setAccountPrivate = "/accounts/set_private/"
    private static let changePassword = "/accounts/change_password/"
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
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for user feed.")
    }
    
    static func getMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaInfo, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for media info by id.")
    }
    
    static func getTagFeed(for tag: String, maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: tagFeed, tag))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for exploring tag.")
    }
    
    static func getRecentActivities(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentActivities)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId), URLQueryItem(name: "activity_module", value: "all")]
            } else {
                urlComponent?.queryItems = [URLQueryItem(name: "activity_module", value: "all")]
            }
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for recent activities.")
    }
    
    static func getRecentFollowingActivities(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentFollowingActivities)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for recent followings activities.")
    }
    
    static func getDirectInbox() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directInbox)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for direct inbox.")
    }
    
    static func getDirectSendTextMessage() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directSendMessage)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for sending direct message.")
    }
    
    static func getDirectThread(id: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: directThread, id))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get direct thread by id.")
    }
    
    static func getRecentDirectRecipients() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentRecipients)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get recent recipients")
    }
    
    static func getRankedDirectRecipients() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, rankedRecipients)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get ranked recipients")
    }
    
    static func setPublicProfile() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPublic)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for set public profile")
    }
    
    static func setPrivateProfile() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPrivate)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for set private profile")
    }
    
    static func getChangePasswordUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changePassword)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for change password.")
    }
}
