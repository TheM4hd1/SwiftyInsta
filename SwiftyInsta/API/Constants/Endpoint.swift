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
    /// The query items.
    var queryItems: [URLQueryItem] { get }
    /// The base path.
    static var base: String { get }
}
public extension Endpoint {
    /// The base path.
    static var base: String { return "https://i.instagram.com/api/v1" }
    /// The base query items.
    var queryItems: [URLQueryItem] { return [] }

    /// Appending.
    func appending(_ path: String) -> Endpoint {
        return AnyEndpoint(rawValue: (rawValue+path)
            .replacingOccurrences(of: "//", with: "/"),
                           queryItems: queryItems)
    }
    /// Query.
    func query<L>(_ items: [String: L?]) -> Endpoint where L: LosslessStringConvertible {
        return AnyEndpoint(rawValue: rawValue,
                           queryItems: queryItems+items.compactMap {
                            $0.value == nil ? nil : URLQueryItem(name: $0.key, value: $0.value.flatMap(String.init))
            })
    }

    // MARK: Accessories.
    /// Populate `rank_token`-
    func rank(_ token: String) -> Endpoint {
        return query(["rank_token": token])
    }
    /// Populate `media_type`-
    func type(_ mediaType: MediaType) -> Endpoint {
        return query(["media_type": mediaType.rawValue])
    }
    /// Populate `max_id`.
    func next(_ nextMaxId: String?) -> Endpoint {
        return query(["max_id": nextMaxId])
    }
    /// Populate `q`.
    func q(_ query: String) -> Endpoint {
        return self.query(["q": query])
    }
    /// Populate `query`.
    func query(_ query: String?) -> Endpoint {
        return self.query(["query": query])
    }

    /// `URL`.
    func url() throws -> URL {
        guard var components = URLComponents(string: Self.base+rawValue) else {
            throw GenericError.invalidEndpoint(Self.base)
        }
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else {
            throw GenericError.invalidEndpoint(rawValue)
        }
        return url
    }
}

/// The endpoints manager.
public struct Endpoints { }
/// `AnyEndpoint`.
public struct AnyEndpoint: Endpoint {
    /// The `rawValue`.
    public var rawValue: String
    /// The query items.
    public var queryItems: [URLQueryItem]
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
    enum Direct: Endpoint {
        /// Inbox.
        case inbox
        /// Send message.
        case text
        /// Thread with identifier.
        case thread(String)
        /// Recent recipients.
        case recentRecipients
        /// Ranked recipients.
        case rankedRecipients

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .inbox: return "/direct_v2/inbox/"
            case .text: return "/direct_v2/threads/broadcast/text/"
            case .thread(let identifier): return "/direct_v2/threads/"+identifier+"/"
            case .recentRecipients: return "/direct_share/recent_recipients/"
            case .rankedRecipients: return "/direct_v2/ranked_recipients/"
            }
        }
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
    enum Feed: Endpoint {
        /// Story feed.
        case reelsTray
        /// Reels media
        case reelsMedia
        /// Tag.
        case tag(String)
        /// Timeline.
        case timeline
        /// User's feed.
        case user(Int)
        /// Reel media.
        case reelMedia(user: Int)
        /// Story feed.
        case story(user: Int)

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .reelsTray: return "/feed/reels_tray/"
            case .reelsMedia: return "/feed/reels_media/"
            case .tag(let tag): return "/feed/tag/"+tag+"/"
            case .timeline: return "/feed/timeline/"
            case .user(let primaryKey): return "/feed/user/\(primaryKey)/"
            case .reelMedia(let primaryKey): return "/feed/user/\(primaryKey)/reel_media/"
            case .story(let primaryKey): return "/feed/user/\(primaryKey)/story"
            }
        }
    }
}

// MARK: Friendships
public extension Endpoints {
    enum Friendships: Endpoint {
        /// Following.
        case folllowing(user: Int)
        /// Followers.
        case followers(user: Int)
        /// Remove follower.
        case remove(user: Int)
        /// Reject friendship.
        case reject(user: Int)
        /// Aprove friendship.
        case approve(user: Int)
        /// Pending friendships.
        case pending
        /// Folllow.
        case follow(user: Int)
        /// Unfollow.
        case unfollow(user: Int)
        /// Status.
        case status(user: Int)
        /// Statuses.
        case statuses
        /// Block.
        case block(user: Int)
        /// Unblock.
        case unblock(user: Int)

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .folllowing(let primaryKey): return "/friendships/\(primaryKey)/following/"
            case .followers(let primaryKey): return "/friendships/\(primaryKey)/followers/"
            case .remove(let primaryKey): return "/friendships/remove_follower/\(primaryKey)/"
            case .reject(let primaryKey): return "/friendships/ignore/\(primaryKey)/"
            case .approve(let primaryKey): return "/friendships/approve/\(primaryKey)/"
            case .pending: return "/friendships/pending/"
            case .follow(let primaryKey): return "/friendships/create/\(primaryKey)/"
            case .unfollow(let primaryKey): return "/friendships/destroy/\(primaryKey)/"
            case .status(let primaryKey): return "/friendships/show/\(primaryKey)/"
            case .statuses: return "/friendships/show_many/"
            case .block(let primaryKey): return "/friendships/block/\(primaryKey)/"
            case .unblock(let primaryKey): return "/friendships/unblock/\(primaryKey)/"
            }
        }
    }
}

// MARK: Highlights
public extension Endpoints {
    enum Highlights: Endpoint {
        /// Highlights.
        case tray(user: Int)

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .tray(let primaryKey): return "/highlights/\(primaryKey)/highlights_tray/"
            }
        }
    }
}

// MARK: Media
public extension Endpoints {
    enum Media: Endpoint {
        /// Info.
        case info(media: String)
        /// Like.
        case like(media: String)
        /// Unlike.
        case unlike(media: String)
        /// Likers.
        case likers(media: String)
        /// Comments.
        case comments(media: String)
        /// Configure.
        case configure
        /// Configure album.
        case configureAlbum
        /// Configure story.
        case configureStory
        /// Post comment.
        case postComment(media: String)
        /// Delete comment.
        case deleteComment(String, media: String)
        /// Delete media.
        case delete(media: String)
        /// Edit media.
        case edit(media: String)
        /// Story viewers.
        case storyViewers(media: String)
        /// Report comment.
        case reportComment(String, media: String)
        /// Permalink.
        case permalink(media: String)
        /// Mark as seen.
        case markAsSeen

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .info(let media): return "/media/"+media+"/info/"
            case .like(let media): return "/media/"+media+"/like/"
            case .unlike(let media): return "/media/"+media+"/unlike/"
            case .likers(let media): return "/media/"+media+"/likers/"
            case .comments(let media): return "/media/"+media+"/comments/"
            case .configure: return "/media/configure/"
            case .configureAlbum: return "/media/configure_sidecar/"
            case .configureStory: return "/media/configure_to_reel/"
            case .postComment(let media): return "/media/"+media+"/comment/"
            case .deleteComment(let comment, let media): return "/media/"+media+"/comment/"+comment+"/delete/"
            case .delete(let media): return "/media/"+media+"/delete/"
            case .edit(let media): return "/media/"+media+"/edit_media/"
            case .storyViewers(let media): return "/media/"+media+"/list_reel_media_viewer/"
            case .reportComment(let comment, let media): return "/media/"+media+"/comment/"+comment+"/flag/"
            case .permalink(let media): return "/media/"+media+"/permalink/"
            case .markAsSeen: return "/media/seen/?reel=1&live_vod=0"
            }
        }
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
    enum Users: Endpoint {
        /// Search.
        case search
        /// Info.
        case info(user: Int)
        /// Blocked.
        case blocked
        /// Report.
        case report(user: Int)

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .search: return "/users/search/"
            case .info(let user): return "/users/\(user)/info/"
            case .blocked: return "/users/blocked_list/"
            case .report(let user): return "/users/\(user)/flag_user/"
            }
        }
    }
}

// MARK: Usertags
public extension Endpoints {
    enum Usertags: Endpoint {
        /// Feed.
        case feed(user: Int)

        /// The raw value.
        public var rawValue: String {
            switch self {
            case .feed(let primaryKey): return "/usertags/\(primaryKey)/feed/"
            }
        }
    }
}
