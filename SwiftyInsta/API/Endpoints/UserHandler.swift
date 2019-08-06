//
//  UserHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class UserHandler: Handler {
    public func current(completionHandler: @escaping (Result<User?, Error>) -> Void) {
        current(delay: nil, completionHandler: completionHandler)
    }

    func current(delay: ClosedRange<Double>?, completionHandler: @escaping (Result<User?, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken]

        requests.parse(User?.self,
                       method: .get,
                       url: Result { try URLs.getCurrentUser() },
                       body: .parameters(body),
                       delay: delay,
                       processingHandler: { $0.user == .none ? nil : User(rawResponse: $0.user) },
                       completionHandler: completionHandler)
    }

    // Its not working yet.
    /*func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
     guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
     httpHelper.sendAsync(method: .get, url: try URLs.getInstagramUrl(), body: [:], header: [:]) { (data, response, error) in
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
     httpHelper.sendAsync(method: .post, url: try URLs.getCreateAccountUrl(), body: body, header: headers, completion: { (data, response, error) in
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

    /// Search for users matching the query.
    public func search(forUsersMatching query: String, completionHandler: @escaping (Result<[User], Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let headers = [Headers.timeZoneOffsetKey: Headers.timeZoneOffsetValue,
                       Headers.countKey: Headers.countValue,
                       Headers.rankTokenKey: storage.rankToken]

        pages.parse(User.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: .init(maxPagesToLoad: 1),
                    at: { _ in try URLs.getUserUrl(username: query) },
                    headers: { _ in headers },
                    processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                    updateHandler: nil) { result, _ in
                        completionHandler(result)
        }
    }

    /// Get user matching username.
    public func user(_ user: User.Reference, completionHandler: @escaping (Result<User?, Error>) -> Void) {
        switch user {
        case .username(let username):
            // fetch username.
            search(forUsersMatching: username) {
                completionHandler($0.map { $0.first(where: { $0.username == username }) })
            }
        case .primaryKey(let pk):
            // load user info directly.
            requests.parse(User?.self,
                           method: .get,
                           url: Result { try URLs.getUserInfo(id: pk) },
                           processingHandler: { $0.user == .none ? nil : User(rawResponse: $0.user) },
                           completionHandler: completionHandler)
        }
    }

    /// Get user's tagged posts.
    public func tagged(user: User.Reference,
                       with paginationParameters: PaginationParameters,
                       updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                       completionHandler: @escaping PaginationCompletionHandler<Media>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.tagged(user: .primaryKey(user!.identity.primaryKey!),
                                   with: paginationParameters,
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load user tags directly.
            pages.parse(Media.self,
                        paginatedResponse: AnyPaginatedResponse.self,
                        with: paginationParameters,
                        at: { try URLs.getUserTagsUrl(userPk: pk,
                                                      rankToken: storage.rankToken,
                                                      maxId: $0.nextMaxId ?? "") },
                        processingHandler: { $0.rawResponse.items.array?.map(Media.init) ?? [] },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get `user`'s **followers**.
    public func following(user: User.Reference,
                          usersMatchinQuery query: String? = nil,
                          with paginationParameters: PaginationParameters,
                          updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                          completionHandler: @escaping PaginationCompletionHandler<User>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.following(user: .primaryKey(user!.identity.primaryKey!),
                                      usersMatchinQuery: query,
                                      with: paginationParameters,
                                      updateHandler: updateHandler,
                                      completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load user followers directly.
            pages.parse(User.self,
                        paginatedResponse: AnyPaginatedResponse.self,
                        with: paginationParameters,
                        at: { try URLs.getUserFollowers(userPk: pk,
                                                        rankToken: storage.rankToken,
                                                        searchQuery: query ?? "",
                                                        maxId: $0.nextMaxId ?? "") },
                        processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get  accounts followed by`user` (**following**).
    public func followed(byUser user: User.Reference,
                         usersMatchinQuery query: String? = nil,
                         with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                         completionHandler: @escaping PaginationCompletionHandler<User>) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.followed(byUser: .primaryKey(user!.identity.primaryKey!),
                                     usersMatchinQuery: query,
                                     with: paginationParameters,
                                     updateHandler: updateHandler,
                                     completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load user following directly.
            pages.parse(User.self,
                        paginatedResponse: AnyPaginatedResponse.self,
                        with: paginationParameters,
                        at: { try URLs.getUserFollowing(userPk: pk,
                                                        rankToken: storage.rankToken,
                                                        searchQuery: query ?? "",
                                                        maxId: $0.nextMaxId ?? "") },
                        processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                        updateHandler: updateHandler,
                        completionHandler: completionHandler)
        }
    }

    /// Get recent activities.
    public func recentActivities(with paginationParameters: PaginationParameters,
                                 updateHandler: LegacyPaginationUpdateHandler<RecentActivitiesModel>?,
                                 completionHandler: @escaping PaginationCompletionHandler<RecentActivitiesModel>) {
        #warning("uses old models.")
        pages.decode(RecentActivitiesModel.self,
                     with: paginationParameters,
                     at: { try URLs.getRecentActivities(maxId: $0.nextMaxId ?? "") },
                     updateHandler: updateHandler,
                     completionHandler: completionHandler)
    }

    /// Get recent following activities.
    public func recentFollowingActivities(with paginationParameters: PaginationParameters,
                                          updateHandler: LegacyPaginationUpdateHandler<RecentFollowingsActivitiesModel>?,
                                          completionHandler: @escaping PaginationCompletionHandler<RecentFollowingsActivitiesModel>) {
        #warning("uses old models.")
        pages.decode(RecentFollowingsActivitiesModel.self,
                     with: paginationParameters,
                     at: { try URLs.getRecentFollowingActivities(maxId: $0.nextMaxId ?? "") },
                     updateHandler: updateHandler,
                     completionHandler: completionHandler)
    }

    /// Unfollow user.
    public func remove(follower user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.remove(follower: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // unfollow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.removeFollowerUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Approve friendship.
    public func approveRequest(from user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.approveRequest(from: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // approve friendship directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.approveFriendshipUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Reject friendship.
    public func rejectRequest(from user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.rejectRequest(from: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // reject friendship directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.rejectFriendshipUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Get all pending friendship requests.
    public func pendingRequests(with paginationParameters: PaginationParameters,
                                updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                                completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.parse(User.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try URLs.pendingFriendshipsUrl(maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Follow user.
    public func follow(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.follow(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.getFollowUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Unfollow user.
    public func unfollow(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.unfollow(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.getUnFollowUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Friendship status.
    public func friendshipStatus(withUser user: User.Reference, completionHandler: @escaping (Result<Friendship, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.friendshipStatus(withUser: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // follow user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.parse(Friendship.self,
                            method: .get,
                            url: Result { try URLs.getFriendshipStatusUrl(for: pk) },
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
     httpHelper.sendAsync(method: .post, url: try URLs.getFriendshipStatusesUrl(), body: body, header: [:]) { (data, response, error) in
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
    public func blocked(with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                        completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.parse(User.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try URLs.getBlockedList(maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.blockedList.array?.map(User.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Block user.
    public func block(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.block(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // block directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.getBlockUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Unblock user.
    public func unblock(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.unblock(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // unblock user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "radio_type": "wifi-none"]

            requests.decode(Status.self,
                            method: .get,
                            url: Result { try URLs.getUnBlockUrl(for: pk) },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /*
     func recoverAccountBy(username: String, completion: @escaping (InstagramResult<AccountRecovery>) -> ()) throws {
     try recoverAccountBy(email: username) { (result) in
     completion(result)
     }
     }
     
     func recoverAccountBy(email: String, completion: @escaping (InstagramResult<AccountRecovery>) -> ()) throws {
     guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
     httpHelper.sendAsync(method: .get, url: try URLs.getInstagramUrl(), body: [:], header: [:]) { (data, response, error) in
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
     httpHelper.sendAsync(method: .post, url: try URLs.getRecoverByEmailUrl(), body: body, header: [:], completion: { (data, response, error) in
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

    /// Report user.
    public func report(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.report(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // report user directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "_uid": storage.dsUserId,
                        "_csrftoken": storage.csrfToken,
                        "user_id": String(pk),
                        "source_name": "profile",
                        "is_spam": "true",
                        "reason_id": "1"]

            requests.decode(Status.self,
                            method: .post,
                            url: Result { try URLs.reportUserUrl(userPk: pk) },
                            body: .parameters(body),
                            completionHandler: { completionHandler($0.map { $0.state == .ok }) })
        }
    }
}
