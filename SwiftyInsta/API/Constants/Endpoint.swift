//
//  Endpoint.swift
//  iOS
//
//  Created by Stefano Bertagno on 25/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A protocol describing a generic `Endpoint`.
public protocol Endpoint {
    /// The raw value.
    var rawValue: String { get }
    /// The base path.
    static var base: String { get }
}
public extension Endpoint {
    /// The base path.
    static var base: String { return "https://i.instagram.com/api/v1" }
    /// Appending.
    func appending(_ path: String) -> AnyEndpoint {
        return AnyEndpoint(rawValue: (rawValue+path)
            .replacingOccurrences(of: "//", with: "/"))
    }
    /// Resolving format.
    func resolving(_ args: Any...) -> AnyEndpoint {
        return AnyEndpoint(rawValue: String(format: rawValue, args))
    }

    /// `URL`.
    func url() throws -> URL {
        guard let url = URL(string: Self.base)?.appendingPathComponent(rawValue) else {
            throw GenericError.invalidEndpoint(rawValue)
        }
        return url
    }
    /// `URL` with `queryParameters`.
    func url<L>(with queryParameters: [String: L?]) throws -> URL! where L: LosslessStringConvertible {
        guard var combine = try URLComponents(url: url(), resolvingAgainstBaseURL: false) else {
            throw GenericError.invalidEndpoint(rawValue)
        }
        let parameters = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value.flatMap(String.init)) }
        combine.queryItems = parameters
        guard let url = combine.url else { throw GenericError.invalidEndpoint(rawValue) }
        return url
    }
}

/// The endpoints manager.
public struct Endpoints { }
/// `AnyEndpoint`.
public struct AnyEndpoint: Endpoint {
    /// The `rawValue`.
    public var rawValue: String
}

// MARK: Authentication
public extension Endpoints {
    enum Authentication: String, Endpoint {
        public static var base: String { return "https://www.instagram.com" }

        /// Home.
        case home = ""
        /// Login.
        case login = "/accounts/login/ajax/"
        /// Two factor.
        case twoFactor = "/accounts/login/ajax/two_factor/"
        /// Resend two factor.
        case sendTwoFactorLoginSms = "/accounts/send_two_factor_login_sms/"
    }
}

// MARK: Accounts
public extension Endpoints {
    enum Accounts: String, Endpoint {
        /// Create.
        case create = "/accounts/create/"
        /// Login.
        case login = "/accounts/login/"
        /// Two factor login.
        case twoFactorLogin = "/accounts/two_factor_login/"
        /// Send two factor login sms.
        case sendTwoFactorLoginSms = "/accounts/send_two_factor_login_sms/"
        /// Change password.
        case changePassword = "/accounts/change_password/"
        /// Current user.
        case current = "/accounts/current_user/"
        /// Logout.
        case logout = "/accounts/logout/"
        /// Set account public.
        case setPublic = "/accounts/set_public/"
        /// Set account private.
        case setPrivate = "/accounts/set_private/"
        /// Edit profile.
        case editProfile = "/accounts/current_user/?edit=true/"
        /// Save edit profile.
        case saveEditProfile = "/accounts/edit_profile/"
        /// Edit biography.
        case editBiography = "/accounts/set_biography/"
        /// Remove profile picture.
        case removeProfilePicture = "/accounts/remove_profile_picture/"
        /// Change profile picture.
        case changeProfilePicture = "/accounts/change_profile_picture/"
        /// Recover by emaill.
        case recoverByEmail = "/accounts/send_recovery_flow_email/"
    }
}

// MARK: Archive
public extension Endpoints {
    enum Archive: String, Endpoint {
        /// Archive.
        case stories = "/archive/reel/day_shells/"
    }
}

// MARK: Direct
public extension Endpoints {
    enum Direct: String, Endpoint {
        /// Inbox.
        case inbox = "/direct_v2/inbox/"
        /// Send message.
        case text = "/direct_v2/threads/broadcast/text/"
        /// Thread.
        case thread = "/direct_v2/threads/%@/"
        /// Recent recipients.
        case recentRecipients = "/direct_share/recent_recipients/"
        /// Ranked recipients.
        case rankedRecipients = "/direct_v2/ranked_recipients/"
    }
}

// MARK: Discover
public extension Endpoints {
    enum Discover: String, Endpoint {
        /// Explore.
        case explore = "/discover/explore/"
    }
}

// MARK: Feed
public extension Endpoints {
    enum Feed: String, Endpoint {
        /// Story feed.
        case story = "/feed/reels_tray/"
        /// Reels media
        case reelsMedia = "/feed/reels_media/"
        /// Tag.
        case tag = "/feed/tag/%@/"
        /// Timeline.
        case timeline = "/feed/timeline/"
        /// User's feed.
        case user = "/feed/user/%ld/"
        /// Reel media.
        case userReelMedia = "/feed/user/%ld/reel_media/"
        /// Story feed.
        case userStory = "/feed/user/%ld/story/"
    }
}

// MARK: Friendships
public extension Endpoints {
    enum Friendships: String, Endpoint {
        /// Following.
        case folllowing = "/friendships/%ld/following/"
        /// Followers.
        case followers = "/friendships/%ld/followers/"
        /// Remove follower.
        case remove = "/friendships/remove_follower/%ld/"
        /// Reject friendship.
        case reject = "/friendships/ignore/%ld/"
        /// Aprove friendship.
        case approve = "/friendships/approve/%ld/"
        /// Pending friendships.
        case pending = "/friendships/pending/"
        /// Folllow.
        case follow = "/friendships/create/%ld/"
        /// Unfollow.
        case unfollow = "/friendships/destroy/%ld/"
        /// Status.
        case status = "/friendships/show/%ld/"
        /// Statuses.
        case statuses = "/friendships/show_many/"
        /// Block.
        case block = "/friendships/block/%ld/"
        /// Unblock.
        case unblock = "/friendships/unblock/%ld/"
    }
}

// MARK: Highlights
public extension Endpoints {
    enum Highlights: String, Endpoint {
        /// Highlights.
        case tray = "/highlights/%ld/highlights_tray/"
    }
}

// MARK: Media
public extension Endpoints {
    enum Media: String, Endpoint {
        /// Info.
        case info = "/media/%@/info/"
        /// Like.
        case like = "/media/%@/like/"
        /// Unlike.
        case unlike = "/media/%@/unlike/"
        /// Likers.
        case likers = "/media/%@/likers/"
        /// Comments.
        case comments = "/media/%@/comments/"
        /// Configure.
        case configureMedia = "/media/configure/"
        /// Configure album.
        case configureMediaAlbum = "/media/configure_sidecar/"
        /// Configure story.
        case configureStory = "/media/configure_to_reel/"
        /// Post comment.
        case postComment = "/media/%@/comment/"
        /// Delete comment.
        case deleteComment = "/media/%@/comment/%@/delete/"
        /// Delete media.
        case deleteMedia = "/media/%@/delete/?media_type=%@/"
        /// Edit media.
        case editMedia = "/media/%@/edit_media/"
        /// Story viewers.
        case storyViewers = "/media/%@/list_reel_media_viewer/"
        /// Report comment.
        case reportComment = "/media/%@/comment/%@/flag/"
        /// Permalink.
        case permalink = "/media/%@/permalink/"
        /// Mark as seen.
        case markAsSeen = "/media/seen/?reel=1&live_vod=0/"
    }
}

// MARK: News
public extension Endpoints {
    enum News: String, Endpoint {
        /// Recent activities
        case activities = "/news/inbox/"
        /// Recent following activities.
        case followingActivities = "/news/"
    }
}

// MARK: Upload
public extension Endpoints {
    enum Upload: String, Endpoint {
        /// Photo.
        case photo = "/upload/photo/"
        /// Video.
        case video = "/upload/video/"
    }
}

// MARK: Users
public extension Endpoints {
    enum Users: String, Endpoint {
        /// Search.
        case search = "/users/search/"
        /// Info.
        case info = "/users/%ld/info/"
        /// Blocked.
        case blocked = "/users/blocked_list/"
        /// Report.
        case report = "/users/%ld/flag_user/"
    }
}

// MARK: Usertags
public extension Endpoints {
    enum Usertags: String, Endpoint {
        /// Feed.
        case feed = "/usertags/%ld/feed/"
    }
}
