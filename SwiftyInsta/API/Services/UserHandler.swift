//
//  UserHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum UserReference {
    case pk(Int)
    case username(String)
}

public class UserHandler: Handler {
    public func current(completionHandler: @escaping (Result<CurrentUserModel, Error>) -> Void) {
        current(delay: nil, completionHandler: completionHandler)
    }

    func current(delay: ClosedRange<Double>?, completionHandler: @escaping (Result<CurrentUserModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken]

        requests.decodeAsync(CurrentUserModel.self,
                             method: .get,
                             url: URLs.getCurrentUser(),
                             body: .parameters(body),
                             delay: delay,
                             completionHandler: completionHandler)
    }

    // swiftlint:disable line_length
    // Its not working yet.
    /*func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: URLs.getInstagramUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // find CSRF token
                let fields = response?.allHeaderFields
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields as! [String : String], for: (response?.url)!)
                for cookie in cookies {
                    if cookie.name == "csrftoken" {
                        HandlerSettings.shared.user!.csrfToken = cookie.value
                        break
                    }
                }

                let content = [
                    "allow_contacts_sync": "true",
                    "sn_result": "API_ERROR:+null",
                    "phone_id": UUID.init().uuidString,
                    "_csrftoken": HandlerSettings.shared.user!.csrfToken,
                    "username": account.username,
                    "first_name": account.firstName,
                    "adid": UUID.init().uuidString,
                    "guid": UUID.init().uuidString,
                    "device_id": RequestMessageModel.generateDeviceId(),
                    "email": account.email,
                    "sn_nonce": "",
                    "force_sign_up_code": "",
                    "waterfall_id": UUID.init().uuidString,
                    "qs_stamp": "",
                    "password": account.password,
                    "gdpr_s": "[0,2,0,null]"
                ]

                let encoder = JSONEncoder()
                let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
                let hash = payload.hmac(algorithm: .SHA256, key: Headers.igSignatureValue)
                // Creating Post Request Body
                let signature = "\(hash).\(payload)"
                let body: [String: Any] = [
                    Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                    Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
                ]

                let headers: [String: String] = [
                    "X-IG-App-ID": "567067343352427",
                    Headers.HeaderXGoogleADID: (HandlerSettings.shared.device!.googleAdId?.uuidString)!
                ]

                guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
                httpHelper.sendAsync(method: .post, url: URLs.getCreateAccountUrl(), body: body, header: headers, completion: { (data, response, error) in
                        if error != nil {
                            completion(false)
                        } else {
                            if let data = data {
                                //print(response)
                                print(String(data: data, encoding: .utf8)!)
                            }
                        }
                    })
            }
        }
    }*/
    // swiftlint:enable line_length

    /// Search for users matching the query.
    public func search(forUsersMatching query: String, completionHandler: @escaping (Result<[UserModel], Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let headers = [Headers.timeZoneOffsetKey: Headers.timeZoneOffsetValue,
                       Headers.countKey: Headers.countValue,
                       Headers.rankTokenKey: storage.rankToken]

        requests.decodeAsync(SearchUserModel.self,
                             method: .get,
                             url: URLs.getUserUrl(username: query),
                             headers: headers,
                             deliverOnResponseQueue: true) {
                                completionHandler($0.map { $0.users ?? [] })
        }
    }

    /// Get user matching username.
    public func user(_ user: UserReference, completionHandler: @escaping (Result<UserModel?, Error>) -> Void) {
        switch user {
        case .username(let username):
            // fetch username.
            search(forUsersMatching: username) {
                completionHandler($0.map { $0.first(where: { $0.username == username })})
            }
        case .pk(let pk):
            // load user info directly.
            requests.decodeAsync(UserInfoModel.self,
                                 method: .get,
                                 url: URLs.getUserInfo(id: pk)) {
                                    completionHandler($0.map { $0.user })
            }
        }
    }

    /// Get user's tagged posts.
    public func tagged(user: UserReference,
                       with paginationParameters: PaginationParameters,
                       updateHandler: PaginationUpdateHandler<UserFeedModel>?,
                       completionHandler: @escaping PaginationCompletionHandler<UserFeedModel>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.tagged(user: .pk(user!.pk!),
                                   with: paginationParameters,
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")), paginationParameters)
                }
            }
        case .pk(let pk):
            // load user tags directly.
            pages.fetch(UserFeedModel.self,
                        with: paginationParameters,
                        at: { URLs.getUserTagsUrl(userPk: pk,
                                                  rankToken: storage.rankToken,
                                                  maxId: $0.nextMaxId ?? "") },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get `user`'s **followers**.
    public func following(user: UserReference,
                          usersMatchinQuery query: String? = nil,
                          with paginationParameters: PaginationParameters,
                          updateHandler: PaginationUpdateHandler<UserShortListModel>?,
                          completionHandler: @escaping PaginationCompletionHandler<UserShortListModel>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.following(user: .pk(user!.pk!),
                                      usersMatchinQuery: query,
                                      with: paginationParameters,
                                      updateHandler: updateHandler,
                                      completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")), paginationParameters)
                }
            }
        case .pk(let pk):
            // load user followers directly.
            pages.fetch(UserShortListModel.self,
                        with: paginationParameters,
                        at: { URLs.getUserFollowers(userPk: pk,
                                                    rankToken: storage.rankToken,
                                                    searchQuery: query ?? "",
                                                    maxId: $0.nextMaxId ?? "") },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get  accounts followed by`user` (**following**).
    public func followed(byUser user: UserReference,
                         usersMatchinQuery query: String? = nil,
                         with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<UserShortListModel>?,
                         completionHandler: @escaping PaginationCompletionHandler<UserShortListModel>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.followed(byUser: .pk(user!.pk!),
                                     usersMatchinQuery: query,
                                     with: paginationParameters,
                                     updateHandler: updateHandler,
                                     completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")), paginationParameters)
                }
            }
        case .pk(let pk):
            // load user following directly.
            pages.fetch(UserShortListModel.self,
                        with: paginationParameters,
                        at: { URLs.getUserFollowing(userPk: pk,
                                                    rankToken: storage.rankToken,
                                                    searchQuery: query ?? "",
                                                    maxId: $0.nextMaxId ?? "") },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get recent activities.
    public func recentActivities(with paginationParameters: PaginationParameters,
                                 updateHandler: PaginationUpdateHandler<RecentActivitiesModel>?,
                                 completionHandler: @escaping PaginationCompletionHandler<RecentActivitiesModel>) {
        pages.fetch(RecentActivitiesModel.self,
                    with: paginationParameters,
                    at: { URLs.getRecentActivities(maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Get recent following activities.
    public func recentFollowingActivities(with paginationParameters: PaginationParameters,
                                          updateHandler: PaginationUpdateHandler<RecentFollowingsActivitiesModel>?,
                                          completionHandler: @escaping PaginationCompletionHandler<RecentFollowingsActivitiesModel>) {
        pages.fetch(RecentFollowingsActivitiesModel.self,
                    with: paginationParameters,
                    at: { URLs.getRecentFollowingActivities(maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Unfollow user.
    public func remove(follower user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.remove(follower: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // unfollow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.removeFollowerUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Approve friendship.
    public func approveRequest(from user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.approveRequest(from: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // approve friendship directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.approveFriendshipUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Reject friendship.
    public func rejectRequest(from user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.rejectRequest(from: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // reject friendship directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.rejectFriendshipUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Get all pending friendship requests.
    public func pendingRequests(completionHandler: @escaping (Result<PendingFriendshipsModel, Error>) -> Void) {
        requests.decodeAsync(PendingFriendshipsModel.self,
                             method: .get,
                             url: URLs.pendingFriendshipsUrl(),
                             completionHandler: completionHandler)
    }

    /// Follow user.
    public func follow(user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.follow(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.getFollowUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Unfollow user.
    public func unfollow(user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.unfollow(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.getUnFollowUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Friendship status.
    public func friendshipStatus(withUser user: UserReference, completionHandler: @escaping (Result<FriendshipStatusModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.friendshipStatus(withUser: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FriendshipStatusModel.self,
                                 method: .get,
                                 url: URLs.getFriendshipStatusUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /*func getFriendshipStatuses(of userIds: [Int], completion: @escaping (InstagramResult<FriendshipStatusesModel>) -> ()) throws {

        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_ids": userIds.map{String($0)}.joined(separator: ", "),
            "radio_type": "wifi-none"
        ]

        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: URLs.getFriendshipStatusesUrl(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FriendshipStatusesModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }*/

    /// Get blocked users.
    public func blocked(completionHandler: @escaping (Result<BlockedUsersModel, Error>) -> Void) {
        requests.decodeAsync(BlockedUsersModel.self,
                             method: .get,
                             url: URLs.getBlockedList(),
                             completionHandler: completionHandler)
    }

    /// Block user.
    public func block(user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.block(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // block directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.getBlockUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    /// Unblock user.
    public func unblock(user: UserReference, completionHandler: @escaping (Result<FollowResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.unblock(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // unblock user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decodeAsync(FollowResponseModel.self,
                                 method: .get,
                                 url: URLs.getUnBlockUrl(for: pk),
                                 body: .parameters(body),
                                 completionHandler: completionHandler)
        }
    }

    // swiftlint:disable line_length
    /*
    func recoverAccountBy(username: String, completion: @escaping (InstagramResult<AccountRecovery>) -> ()) throws {
        try recoverAccountBy(email: username) { (result) in
            completion(result)
        }
    }

    func recoverAccountBy(email: String, completion: @escaping (InstagramResult<AccountRecovery>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: URLs.getInstagramUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .unknown, value: nil))
            } else {
                // find CSRF token
                let fields = response?.allHeaderFields
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields as! [String : String], for: (response?.url)!)

                for cookie in cookies {
                    if cookie.name == "csrftoken" {
                        HandlerSettings.shared.user!.csrfToken = cookie.value
                        break
                    }
                }

                let body = [
                    "query": email,
                    "adid": UUID.init().uuidString,
                    "device_id": RequestMessageModel.generateDeviceId(),
                    "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
                    "_csrftoken": HandlerSettings.shared.user!.csrfToken
                ]

                guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
                httpHelper.sendAsync(method: .post, url: URLs.getRecoverByEmailUrl(), body: body, header: [:], completion: { (data, response, error) in
                    if let error = error {
                        completion(Return.fail(error: error, response: .fail, value: nil))
                    } else {
                        if let data = data {
                            if response?.statusCode == 200 {
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                do {
                                    let value = try decoder.decode(AccountRecovery.self, from: data)
                                    completion(Return.success(value: value))
                                } catch {
                                    completion(Return.fail(error: error, response: .ok, value: nil))
                                }
                            } else {
                                completion(Return.fail(error: error, response: .wrongRequest, value: nil))
                            }
                        }
                    }
                })
            }
        }
    }*/
    // swiftlint:enable line_length

    /// Report user.
    public func report(user: UserReference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.report(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // report user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "source_name": "profile",
                        "is_spam": "true",
                        "reason_id": "1"]

            requests.decodeAsync(BaseStatusResponseModel.self,
                                 method: .post,
                                 url: URLs.reportUserUrl(userPk: pk),
                                 body: .parameters(body),
                                 completionHandler: { completionHandler($0.map { $0.isOk() }) })
        }
    }
}
