//
//  Endpoint.swift
//  iOS
//
//  Created by Stefano Bertagno on 25/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `struct` holding reference to specific endpoints.
public struct Endpoint {
    /// An `enum` providing for `Authentication` endpoints.
    enum Authentication: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Home.
        case home = "https://www.instagram.com"
        /// Login.
        case login = "https://www.instagram.com/accounts/login/ajax/"
        /// Two factor.
        case twoFactor = "https://www.instagram.com/accounts/login/ajax/two_factor/"
        /// Resend two factor.
        case sendTwoFactorLoginSms = "https://www.instagram.com/accounts/send_two_factor_login_sms/"
    }

    /// An `enum` providing for `Accounts` endpoints.
    enum Accounts: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Create.
        case create = "https://i.instagram.com/api/v1/accounts/create/"
        /// Login.
        case login = "https://i.instagram.com/api/v1/accounts/login/"
        /// Two factor login.
        case twoFactorLogin = "https://i.instagram.com/api/v1/accounts/two_factor_login/"
        /// Send two factor login sms.
        case sendTwoFactorLoginSms = "https://i.instagram.com/api/v1/accounts/send_two_factor_login_sms/"
        /// Change password.
        case changePassword = "https://i.instagram.com/api/v1/accounts/change_password/"
        /// Current user.
        case current = "https://i.instagram.com/api/v1/accounts/current_user/?edit=true"
        /// Logout.
        case logout = "https://i.instagram.com/api/v1/accounts/logout/"
        /// Set account public.
        case setPublic = "https://i.instagram.com/api/v1/accounts/set_public/"
        /// Set account private.
        case setPrivate = "https://i.instagram.com/api/v1/accounts/set_private/"
        /// Edit profile.
        case editProfile = "https://i.instagram.com/api/v1/accounts/current_user/?edit=true/"
        /// Save edit profile.
        case saveEditProfile = "https://i.instagram.com/api/v1/accounts/edit_profile/"
        /// Edit biography.
        case editBiography = "https://i.instagram.com/api/v1/accounts/set_biography/"
        /// Remove profile picture.
        case removeProfilePicture = "https://i.instagram.com/api/v1/accounts/remove_profile_picture/"
        /// Change profile picture.
        case changeProfilePicture = "https://i.instagram.com/api/v1/accounts/change_profile_picture/"
        /// Recover by emaill.
        case recoverByEmail = "https://i.instagram.com/api/v1/accounts/send_recovery_flow_email/"
        /// Challenge resolve
        case challenge = "https://i.instagram.com/api/v1/{apiPath}/"
        /// Launcher Sync
        case launcherSync = "https://i.instagram.com/api/v1/launcher/sync/"
        /// Challenge BloksAction
        case challengeBloksAction = "https://i.instagram.com/api/v1/bloks/apps/{bloksAction}/"
    }

    /// An `enum` providing for `Archive` endpoints.
    enum Archive: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Stories.
        case stories = "https://i.instagram.com/api/v1/archive/reel/day_shells/"
    }

    /// An `enum` providing for `Direct` endpoints.
    enum Direct: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Inbox.
        case inbox = "https://i.instagram.com/api/v1/direct_v2/inbox/"
        /// Send message.
        case text = "https://i.instagram.com/api/v1/direct_v2/threads/broadcast/text/"
        /// Thread with identifier.
        case thread = "https://i.instagram.com/api/v1/direct_v2/threads/{threadId}/"
        /// Recent recipients.
        case recentRecipients = "https://i.instagram.com/api/v1/direct_share/recent_recipients/"
        /// Ranked recipients.
        case rankedRecipients = "https://i.instagram.com/api/v1/direct_v2/ranked_recipients/"
    }

    /// An `enum` providing for `Discover` endpoints.
    enum Discover: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Explore.
        case explore = "https://i.instagram.com/api/v1/discover/explore/"
    }

    /// An `enum` providing for `Feed` endpoints.
    enum Feed: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Story feed.
        case reelsTray = "https://i.instagram.com/api/v1/feed/reels_tray/"
        /// Reels media.
        case reelsMedia = "https://i.instagram.com/api/v1/feed/reels_media/"
        /// Liked media.
        case liked = "https://i.instagram.com/api/v1/feed/liked/"
        /// Tag.
        case tag = "https://i.instagram.com/api/v1/feed/tag/{tagId}/"
        /// Timeline.
        case timeline = "https://i.instagram.com/api/v1/feed/timeline/"
        /// User's feed.
        case user = "https://i.instagram.com/api/v1/feed/user/{userPk}/"
        /// Reel media
        case reelMedia = "https://i.instagram.com/api/v1/feed/user/{userPk}/reel_media/"
        /// Story feed.
        case story = "https://i.instagram.com/api/v1/feed/user/{userPk}/story"
    }

    /// An `enum` providing for `Friendships` enddpoints.
    enum Friendships: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Following.
        case folllowing = "https://i.instagram.com/api/v1/friendships/{userPk}/following/"
        /// Followers.
        case followers = "https://i.instagram.com/api/v1/friendships/{userPk}/followers/"
        /// Remove follower.
        case remove = "https://i.instagram.com/api/v1/friendships/remove_follower/{userPk}/"
        /// Reject request.
        case reject = "https://i.instagram.com/api/v1/friendships/ignore/{userPk}/"
        /// Approve request.
        case approve = "https://i.instagram.com/api/v1/friendships/approve/{userPk}/"
        /// Pending requests.
        case pending = "https://i.instagram.com/api/v1/friendships/pending/"
        /// Follow.
        case follow = "https://i.instagram.com/api/v1/friendships/create/{userPk}/"
        /// Unfollow.
        case unfollow = "https://i.instagram.com/api/v1/friendships/destroy/{userPk}/"
        /// Friendship status.
        case status = "https://i.instagram.com/api/v1/friendships/show/{userPk}/"
        /// Friendship statuses.
        case statuses = "https://i.instagram.com/api/v1/friendships/show_many/"
        /// Block.
        case block = "https://i.instagram.com/api/v1/friendships/block/{userPk}/"
        /// Unblock.
        case unblock = "https://i.instagram.com/api/v1/friendships/unblock/{userPk}/"
    }

    /// An `enum` providing for `Highlights` endpoints.
    enum Highlights: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Highlights.
        case tray = "https://i.instagram.com/api/v1/highlights/{userPk}/highlights_tray/"
    }

    /// An `enum` providing for `Media` endpoints.
    enum Media: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Media info.
        case info = "https://i.instagram.com/api/v1/media/{mediaId}/info/"
        /// Like.
        case like = "https://i.instagram.com/api/v1/media/{mediaId}/like/?d=1"
        /// Unlike.
        case unlike = "https://i.instagram.com/api/v1/media/{mediaId}/unlike/"
        /// Likers.
        case likers = "https://i.instagram.com/api/v1/media/{mediaId}/likers/"
        /// Comments.
        case comments = "https://i.instagram.com/api/v1/media/{mediaId}/comments/"
        /// Configure.
        case configure = "https://i.instagram.com/api/v1/media/configure/"
        /// Album.
        case configureAlbum = "https://i.instagram.com/api/v1/media/configure_sidecar/"
        /// Story.
        case configureStory = "https://i.instagram.com/api/v1/media/configure_to_reel/"
        /// Post comment.
        case postComment = "https://i.instagram.com/api/v1/media/{mediaId}/comment/"
        /// Delete comment.
        case deleteComment = "https://i.instagram.com/api/v1/media/{mediaId}/comment/bulk_delete/"
        /// Delete.
        case delete = "https://i.instagram.com/api/v1/media/{mediaId}/delete/"
        /// Edit.
        case edit = "https://i.instagram.com/api/v1/media/{mediaId}/edit_media/"
        /// Story viewers.
        case storyViewers = "https://i.instagram.com/api/v1/media/{mediaId}/list_reel_media_viewer/"
        /// Report comment.
        case reportComment = "https://i.instagram.com/api/v1/media/{mediaId}/comment/{commentId}/flag/"
        /// Permalink.
        case permalink = "https://i.instagram.com/api/v1/media/{mediaId}/permalink/"
        /// Mark stories as seen.
        case markAsSeen = "https://i.instagram.com/api/v2/media/seen/?reel=1&live_vod=0"
    }

    /// An `enum` provoding for `News` endpoints.
    enum News: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Recent activities
        case activities = "https://i.instagram.com/api/v1/news/inbox/"
        /// Recent following activities.
        case followingActivities = "https://i.instagram.com/api/v1/news/"
    }

    /// An `enum` provoding for `Upload` endpoints.
    enum Upload: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Photo.
        case photo = "https://i.instagram.com/rupload_igphoto/{uploadId}"
        /// Video.
        case video = "https://i.instagram.com/rupload_igvideo/{uploadId}"
        /// Finish upload for video.
        case finish = "https://i.instagram.com/api/v1/media/upload_finish/"
    }

    /// An `enum` providing for `Users` endpoints.
    enum Users: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Search.
        case search = "https://i.instagram.com/api/v1/users/search/"
        /// Info.
        case info = "https://i.instagram.com/api/v1/users/{userPk}/info/"
        /// Blocked.
        case blocked = "https://i.instagram.com/api/v1/users/blocked_list/"
        /// Report.
        case report = "https://i.instagram.com/api/v1/users/{userPk}/flag_user/"
    }

    /// An `enum` providing for `UserTags` endpoints.
    enum UserTags: EndpointPath, CaseIterable, RawEndpointRepresentable {
        /// Feed.
        case feed = "https://i.instagram.com/api/v1/usertags/{userPk}/feed/"
    }
}
