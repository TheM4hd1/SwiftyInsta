//
//  try URLs.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/31/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// Private Instagram API
struct URLs {
    private init() {}

    // MARK: - Base Url
    private static let instagramUrl = "https://i.instagram.com"
    private static let instagramCookieUrl = "https://www.instagram.com"
    private static let api = "/api"
    private static let apiVersion = "/v1"
    private static let apiSuffix = api + apiVersion
    private static let baseInstagramApiUrl = instagramUrl + apiSuffix

    // MARK: - Login
    private static let loginPath = "/accounts/login/ajax/"
    private static let twoFactorPath = "/accounts/login/ajax/two_factor/"
    private static let twoFactorResendPath = "/accounts/send_two_factor_login_sms/"

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
    private static let removeFollower = "/friendships/remove_follower/%ld/"
    private static let rejectFriendship = "/friendships/ignore/%ld/"
    private static let approveFriendship = "/friendships/approve/%ld/"
    private static let pendingFriendships = "/friendships/pending/"
    private static let followUser = "/friendships/create/%ld/"
    private static let unFollowUser = "/friendships/destroy/%ld/"
    private static let friendshipStatus = "/friendships/show/%ld"
    private static let friendshipStatuses = "/friendships/show_many/"
    private static let blockedList = "/users/blocked_list/"
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
    private static let storyHighlights = "/highlights/%ld/highlights_tray/"
    private static let reportComment = "/media/%@/comment/%@/flag/"
    private static let reportUser = "/users/%ld/flag_user/"
    private static let reelsMediaFeed = "/feed/reels_media/"
    private static let permalink = "/media/%@/permalink/"
    private static let storyArchive = "/archive/reel/day_shells/"

    // MARK: - Methods
    static func home() throws -> URL {
        if let url = URL(string: instagramCookieUrl) { return url }
        throw GenericError.invalidUrl
    }

    static func login() throws -> URL {
        if let url =  URL(string: String(format: "%@%@", instagramCookieUrl, loginPath)) { return url }
        throw GenericError.invalidUrl
    }

    static func checkpoint(url: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, url)) { return url }
        throw GenericError.invalidUrl
    }

    static func twoFactor() throws -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, twoFactorPath)) { return url }
        throw GenericError.invalidUrl
    }

    static func resendTwoFactorCode() throws -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, twoFactorResendPath)) { return url }
        throw GenericError.invalidUrl
    }

    static func getInstagramUrl() throws -> URL {
        if let url = URL(string: instagramUrl) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getCreateAccountUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountCreate)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getLoginUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogin) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getLogoutUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogout) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUserUrl(username: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, searchUser)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponent?.queryItems = [URLQueryItem(name: "q", value: username)]
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getUserFollowing(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") throws -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            throw GenericError.invalidUrl        }

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
        throw GenericError.invalidUrl
    }

    static func getUserFollowers(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") throws -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            throw GenericError.invalidUrl        }

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
        throw GenericError.invalidUrl
    }

    static func getCurrentUser() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, currentUser)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getExploreFeedUrl(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, exploreFeed)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getUserTimeLineUrl(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, userTimeLine)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getUserFeedUrl(userPk: Int?, maxId: String = "") throws -> URL {
        guard let userPk = userPk else {
            throw GenericError.invalidUrl        }

        if let url = URL(string: String(format: "%@%@%ld", baseInstagramApiUrl, userFeed, userPk)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaInfo, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getTagFeed(for tag: String, maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: tagFeed, tag))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
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
        throw GenericError.invalidUrl
    }

    static func getRecentFollowingActivities(maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentFollowingActivities)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getDirectInbox() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directInbox)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getDirectSendTextMessage() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directSendMessage)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getDirectThread(id: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: directThread, id))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getRecentDirectRecipients() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentRecipients)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getRankedDirectRecipients() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, rankedRecipients)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func setPublicProfile() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPublic)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func setPrivateProfile() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPrivate)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getChangePasswordUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changePassword)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUserInfo(id: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userInfo, id))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getLikeMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: likeMedia, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUnLikeMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unlikeMedia, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getComments(for mediaId: String, maxId: String = "") throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaComments, mediaId))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func removeFollowerUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: removeFollower, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func approveFriendshipUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: approveFriendship, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func rejectFriendshipUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: rejectFriendship, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func pendingFriendshipsUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, pendingFriendships)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getFollowUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: followUser, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUnFollowUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unFollowUser, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getFriendshipStatusUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@/", baseInstagramApiUrl, String(format: friendshipStatus, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getFriendshipStatusesUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, friendshipStatuses)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getBlockedList() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, blockedList)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getBlockUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: blockUser, user))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUnBlockUrl(for user: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unBlockUser, user))) {
            return url
        }
        throw GenericError.invalidUrl
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
        throw GenericError.invalidUrl
    }

    static func getUploadPhotoUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadPhoto)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getConfigureMediaUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMedia)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getConfigureMediaAlbumUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMediaAlbum)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getPostCommentUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: postComment, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getDeleteCommentUrl(mediaId: String, commentId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteComment, mediaId, commentId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getDeleteMediaUrl(mediaId: String, mediaType: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteMedia, mediaId, mediaType))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUploadVideoUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadVideo)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getStoryFeedUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, storyFeed)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getUserStoryUrl(userId: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStory, userId))) {
            return url
        } else {
            throw GenericError.invalidUrl        }
    }

    static func getUserStoryFeed(userId: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStoryFeed, userId))) {
            return url
        } else {
            throw GenericError.invalidUrl        }
    }

    static func getConfigureStoryUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureStory)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getEditProfileUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editProfile)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getSaveEditProfileUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, saveEditProfile)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getEditBiographyUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editBiography)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getRemoveProfilePictureUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, removeProfilePicture)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getChangeProfilePictureUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changeProfilePicture)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getChallengeLoginUrl(url: String, guid: String, deviceId: String) throws -> URL {
        if let url = URL(string: url) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queries = [URLQueryItem(name: "guid", value: guid), URLQueryItem(name: "device_id", value: deviceId)]
            urlComponent?.queryItems = queries
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getVerifyLoginUrl(challenge: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, challenge)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getEditMediaUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: editMedia, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getMediaLikersUrl(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaLikers, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getInstagramCookieUrl() throws -> URL {
        if let url = URL(string: instagramCookieUrl) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getTwoFactorLoginUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountTwoFactorLogin)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getSendTwoFactorLoginSmsUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountSendTwoFactorLoginSms) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getRecoverByEmailUrl() throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + recoverByEmail) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getStoryViewersUrl(pk: String, maxId: String) throws -> URL {
        if let url = URL(string: baseInstagramApiUrl + String(format: storyViewers, pk)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)

            var queries = [URLQueryItem]()
            if !maxId.isEmpty {
                queries = [URLQueryItem(name: "max_id", value: maxId)]
            }

            urlComponent?.queryItems = queries
            return (urlComponent?.url)!
        }
        throw GenericError.invalidUrl
    }

    static func getStoryHighlightsUrl(userPk: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: storyHighlights, userPk))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func markStoriesAsSeenUrl() throws -> URL {
        if let url = URL(string: "https://i.instagram.com/api/v2/media/seen/?reel=1&live_vod=0") { return url }
        throw GenericError.invalidUrl
    }

    static func reportCommentUrl(mediaId: String, commentId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: reportComment, mediaId, commentId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func reportUserUrl(userPk: Int) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: reportUser, userPk))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getReelsMediaFeed() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, reelsMediaFeed)) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getPermalink(mediaId: String) throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: permalink, mediaId))) {
            return url
        }
        throw GenericError.invalidUrl
    }

    static func getStoryArchiveUrl() throws -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, storyArchive)) {
            return url
        }
        throw GenericError.invalidUrl
    }
}
