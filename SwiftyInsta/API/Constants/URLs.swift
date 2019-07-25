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

    // MARK: - Methods
    static func home() -> URL {
        if let url = URL(string: instagramCookieUrl) { return url }
        fatalError("Invalid url.")
    }

    static func login() -> URL {
        if let url =  URL(string: String(format: "%@%@", instagramCookieUrl, loginPath)) { return url }
        fatalError("Invalid url.")
    }

    static func checkpoint(url: String) -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, url)) { return url }
        fatalError("Invalid url.")
    }

    static func twoFactor() -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, twoFactorPath)) { return url }
        fatalError("Invalid url.")
    }

    static func resendTwoFactorCode() -> URL {
        if let url = URL(string: String(format: "%@%@", instagramCookieUrl, twoFactorResendPath)) { return url }
        fatalError("Invalid url.")
    }

    static func getInstagramUrl() -> URL {
        if let url = URL(string: instagramUrl) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getCreateAccountUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountCreate)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getLoginUrl() -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogin) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getLogoutUrl() -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountLogout) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUserUrl(username: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, searchUser)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponent?.queryItems = [URLQueryItem(name: "q", value: username)]
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getUserFollowing(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            fatalError("Invalid url.")        }

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
        fatalError("Invalid url.")
    }

    static func getUserFollowers(userPk: Int?, rankToken: String?, searchQuery: String = "", maxId: String = "") -> URL {
        guard let userPk = userPk, let rankToken = rankToken else {
            fatalError("Invalid url.")        }

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
        fatalError("Invalid url.")
    }

    static func getCurrentUser() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, currentUser)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getExploreFeedUrl(maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, exploreFeed)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getUserTimeLineUrl(maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, userTimeLine)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getUserFeedUrl(userPk: Int?, maxId: String = "") -> URL {
        guard let userPk = userPk else {
            fatalError("Invalid url.")        }

        if let url = URL(string: String(format: "%@%@%ld", baseInstagramApiUrl, userFeed, userPk)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getMediaUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaInfo, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getTagFeed(for tag: String, maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: tagFeed, tag))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getRecentActivities(maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentActivities)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId), URLQueryItem(name: "activity_module", value: "all")]
            } else {
                urlComponent?.queryItems = [URLQueryItem(name: "activity_module", value: "all")]
            }
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getRecentFollowingActivities(maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentFollowingActivities)) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getDirectInbox() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directInbox)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getDirectSendTextMessage() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, directSendMessage)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getDirectThread(id: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: directThread, id))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getRecentDirectRecipients() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, recentRecipients)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getRankedDirectRecipients() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, rankedRecipients)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func setPublicProfile() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPublic)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func setPrivateProfile() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, setAccountPrivate)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getChangePasswordUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changePassword)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUserInfo(id: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userInfo, id))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getLikeMediaUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: likeMedia, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUnLikeMediaUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unlikeMedia, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getComments(for mediaId: String, maxId: String = "") -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaComments, mediaId))) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if !maxId.isEmpty {
                urlComponent?.queryItems = [URLQueryItem(name: "max_id", value: maxId)]
            }

            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func removeFollowerUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: removeFollower, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func approveFriendshipUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: approveFriendship, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func rejectFriendshipUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: rejectFriendship, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func pendingFriendshipsUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, pendingFriendships)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getFollowUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: followUser, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUnFollowUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unFollowUser, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getFriendshipStatusUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@/", baseInstagramApiUrl, String(format: friendshipStatus, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getFriendshipStatusesUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, friendshipStatuses)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getBlockedList() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, blockedList)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getBlockUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: blockUser, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUnBlockUrl(for user: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: unBlockUser, user))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUserTagsUrl(userPk: Int, rankToken: String, maxId: String = "") -> URL {
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
        fatalError("Invalid url.")
    }

    static func getUploadPhotoUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadPhoto)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getConfigureMediaUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMedia)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getConfigureMediaAlbumUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureMediaAlbum)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getPostCommentUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: postComment, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getDeleteCommentUrl(mediaId: String, commentId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteComment, mediaId, commentId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getDeleteMediaUrl(mediaId: String, mediaType: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: deleteMedia, mediaId, mediaType))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUploadVideoUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, uploadVideo)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getStoryFeedUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, storyFeed)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getUserStoryUrl(userId: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStory, userId))) {
            return url
        } else {
            fatalError("Invalid url.")        }
    }

    static func getUserStoryFeed(userId: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: userStoryFeed, userId))) {
            return url
        } else {
            fatalError("Invalid url.")        }
    }

    static func getConfigureStoryUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, configureStory)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getEditProfileUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editProfile)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getSaveEditProfileUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, saveEditProfile)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getEditBiographyUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, editBiography)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getRemoveProfilePictureUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, removeProfilePicture)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getChangeProfilePictureUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, changeProfilePicture)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getChallengeLoginUrl(url: String, guid: String, deviceId: String) -> URL {
        if let url = URL(string: url) {
            var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queries = [URLQueryItem(name: "guid", value: guid), URLQueryItem(name: "device_id", value: deviceId)]
            urlComponent?.queryItems = queries
            return (urlComponent?.url)!
        }
        fatalError("Invalid url.")
    }

    static func getVerifyLoginUrl(challenge: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, challenge)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getEditMediaUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: editMedia, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getMediaLikersUrl(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: mediaLikers, mediaId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getInstagramCookieUrl() -> URL {
        if let url = URL(string: instagramCookieUrl) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getTwoFactorLoginUrl() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, accountTwoFactorLogin)) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getSendTwoFactorLoginSmsUrl() -> URL {
        if let url = URL(string: baseInstagramApiUrl + accountSendTwoFactorLoginSms) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getRecoverByEmailUrl() -> URL {
        if let url = URL(string: baseInstagramApiUrl + recoverByEmail) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getStoryViewersUrl(pk: String) -> URL {
        if let url = URL(string: baseInstagramApiUrl + String(format: storyViewers, pk)) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func getStoryHighlightsUrl(userPk: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: storyHighlights, userPk))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func markStoriesAsSeenUrl() -> URL {
        if let url = URL(string: "https://i.instagram.com/api/v2/media/seen/?reel=1&live_vod=0") { return url }
        fatalError("Invalid url.")
    }

    static func reportCommentUrl(mediaId: String, commentId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: reportComment, mediaId, commentId))) {
            return url
        }
        fatalError("Invalid url.")
    }

    static func reportUserUrl(userPk: Int) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: reportUser, userPk))) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getReelsMediaFeed() -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, reelsMediaFeed)) {
            return url
        }

        fatalError("Invalid url.")
    }

    static func getPermalink(mediaId: String) -> URL {
        if let url = URL(string: String(format: "%@%@", baseInstagramApiUrl, String(format: permalink, mediaId))) {
            return url
        }

        fatalError("Invalid url.")
    }
}
