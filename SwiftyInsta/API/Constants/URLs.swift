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
    private static let instagramCookieUrl = "https://www.instagram.com/"
    private static let api = "/api"
    private static let apiVersion = "/v1"
    private static let apiSuffix = api + apiVersion
    private static let baseInstagramApiUrl = instagramUrl + apiSuffix

    // MARK: - Endpoints
    private static let accountCreate = "/accounts/create/"
    private static let accountLogin = "/accounts/login/"
    private static let accountTwoFactorLogin = "/accounts/two_factor_login/"
    private static let accountSendTwoFactorLoginSms = "/accounts/send_two_factor_login_sms/"
    private static let accountChangePassword = "/accounts/change_password/"
    private static let accountLogout = "/accounts/logout/"
    private static let searchUser = "/users/search"
    private static let userInfo = "/users/%ld/info/"
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
    private static let likeMedia = "/media/%@/like/"
    private static let unlikeMedia = "/media/%@/unlike/"
    private static let mediaLikers = "/media/%@/likers/"
    private static let mediaComments = "/media/%@/comments/"
    private static let followUser = "/friendships/create/%ld/"
    private static let unFollowUser = "/friendships/destroy/%ld/"
    private static let friendshipStatus = "/friendships/show/%ld"
    private static let blockUser = "/friendships/block/%ld/"
    private static let unBlockUser = "/friendships/unblock/%ld/"
    private static let userTags = "/usertags/%ld/feed/"
    private static let uploadPhoto = "/upload/photo/"
    private static let configureMedia = "/media/configure/"
    private static let configureMediaAlbum = "/media/configure_sidecar/"
    private static let postComment = "/media/%@/comment/"
    private static let deleteComment = "/media/%@/comment/%@/delete/"
    private static let deleteMedia = "/media/%@/delete/?media_type=%@"
    private static let uploadVideo = "/upload/video/"
    private static let storyFeed = "/feed/reels_tray/"
    private static let userStory = "/feed/user/%ld/reel_media/"
    private static let userStoryFeed = "/feed/user/%ld/story/"
    private static let configureStory = "/media/configure_to_reel/"
    private static let editProfile = "/accounts/current_user/?edit=true"
    private static let saveEditProfile = "/accounts/edit_profile/"
    private static let editBiography = "/accounts/set_biography/"
    private static let removeProfilePicture = "/accounts/remove_profile_picture/"
    private static let changeProfilePicture = "/accounts/change_profile_picture/"
    private static let editMedia = "/media/%@/edit_media/"
    private static let recoverByEmail = "/accounts/send_recovery_flow_email/"
    private static let storyViewers = "/media/%@/list_reel_media_viewer/"
    
    
    // MARK: - Methods
    
    static func getInstagramUrl() throws -> URL {
        if let url = URL(string: instagramUrl) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram main url.")
    }
    
    static func getCreateAccountUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountCreate)) {
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
    
    static func getUserInfo(id: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userInfo, id))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get userinfo.")
    }
    
    static func getLikeMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: likeMedia, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for like media.")
    }
    
    static func getUnLikeMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unlikeMedia, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for unlike media.")
    }
    
    static func getComments(for mediaId: String, maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaComments, mediaId))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get media comments.")
    }
    
    static func getFollowUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: followUser, user))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for follow user.")
    }
    
    static func getUnFollowUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unFollowUser, user))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for unfollow user.")
    }
    
    static func getFriendshipStatusUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@/", baseInstagramApiUrl, String(format: friendshipStatus, user))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for friendship status.")
    }
    
    static func getBlockUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: blockUser, user))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for blocking user.")
    }
    
    static func getUnBlockUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unBlockUser, user))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for unblocking user.")
    }
    
    static func getUserTagsUrl(userPk: Int, rankToken: String, maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userTags, userPk))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            var queries = [
                URLQueryItem(name: "rank_token", value: rankToken),
                URLQueryItem(name: "ranked_content", value: "true")
            ]
            
            if !maxId.isEmpty {
                queries.append(URLQueryItem(name: "max_id", value: maxId))
            }
            urlComponent?.queryItems = queries
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get user tags.")
    }
    
    static func getUploadPhotoUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadPhoto)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for upload photo.")
    }
    
    static func getConfigureMediaUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMedia)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for configuring media.")
    }
    
    static func getConfigureMediaAlbumUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMediaAlbum)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for configuring media album.")
    }
    
    static func getPostCommentUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: postComment, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for post comment.")
    }
    
    static func getDeleteCommentUrl(mediaId: String, commentId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteComment, mediaId, commentId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for delete comment.")
    }
    
    static func getDeleteMediaUrl(mediaId: String, mediaType: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteMedia, mediaId, mediaType))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for delete media.")
    }
    
    static func getUploadVideoUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadVideo)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for upload video.")
    }
    
    static func getStoryFeedUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, storyFeed)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for get stories feed.")
    }
    
    static func getUserStoryUrl(userId: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStory, userId))) {
            return url
        } else {
            throw CustomErrors.urlCreationFaild("Cant create URL for get user story.")
        }
    }
    
    static func getUserStoryFeed(userId: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStoryFeed, userId))) {
            return url
        } else {
            throw CustomErrors.urlCreationFaild("Cant create URL for get user story feed.")
        }
    }
    
    static func getConfigureStoryUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureStory)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for configuring story.")
    }
    
    static func getEditProfileUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editProfile)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for editing profile.")
    }
    
    static func getSaveEditProfileUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, saveEditProfile)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for editing profile.")
    }
    
    static func getEditBiographyUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editBiography)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for editing biography.")
    }
    
    static func getRemoveProfilePictureUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, removeProfilePicture)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for removing profile picture.")
    }
    
    static func getChangeProfilePictureUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changeProfilePicture)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for changing profile picture.")
    }
    
    static func getChallengeLoginUrl(url: String, guid: String, deviceId: String) throws -> URL {
        if let url = URL(string: url) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queries = [URLQueryItem(name: "guid", value: guid), URLQueryItem(name: "device_id", value: deviceId)]
            urlComponent?.queryItems = queries
            return (urlComponent?.url)!
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for challenge login.")
    }
    
    static func getVerifyLoginUrl(challenge: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, challenge)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for verify login.")
    }
    
    static func getEditMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: editMedia, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for verify login.")
    }
    
    static func getMediaLikersUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaLikers, mediaId))) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for media likers.")
    }
    
    static func getInstagramCookieUrl() throws -> URL {
        if let url = URL(string: instagramCookieUrl) {
            return url
        }
        
        throw CustomErrors.urlCreationFaild("Cant create URL for instagram cookies.")
    }
    
    static func getTwoFactorLoginUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountTwoFactorLogin)) {
            return url
        }
        
        throw CustomErrors.urlCreationFaild("Cant create URL for two factor login.")
    }
    
    static func getSendTwoFactorLoginSmsUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountSendTwoFactorLoginSms) {
            return url
        }
        
        throw CustomErrors.urlCreationFaild("Cant create URL for send two factor login sms.")
    }
    
    static func getRecoverByEmailUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + recoverByEmail) {
            return url
        }
        
        throw CustomErrors.urlCreationFaild("Cant create URL for recovery by email.")
    }
    
    static func getStoryViewersUrl(pk: String) throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + String(format: storyViewers, pk)) {
            return url
        }
        throw CustomErrors.urlCreationFaild("Cant create URL for story viewers.")
    }
}
