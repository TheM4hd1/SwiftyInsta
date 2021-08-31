//
//  UserHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public final class UserHandler: Handler {
    public func current(delay: ClosedRange<Double>?, completionHandler: @escaping (Result<User, Error>) -> Void) {
        requests.request(User.self,
                         method: .get,
                         endpoint: Endpoint.Accounts.current,
                         delay: delay,
                         process: { User(rawResponse: $0.user) },
                         completion: completionHandler)
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
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let headers = [Constants.timeZoneOffsetKey: Constants.timeZoneOffsetValue,
                       Constants.countKey: Constants.countValue,
                       Constants.rankTokenKey: storage.rankToken]

        pages.request(User.self,
                      page: AnyPaginatedResponse.self,
                      with: .init(maxPagesToLoad: 1),
                      endpoint: { _ in Endpoint.Users.search.q(query) },
                      headers: { _ in headers },
                      splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                      update: nil) { result, _ in
                        completionHandler(result)
        }
    }

    /// Get user matching username.
    public func user(_ user: User.Reference, completionHandler: @escaping (Result<User, Error>) -> Void) {
        switch user {
        case .me:
            // fetch current user.
            current(delay: nil, completionHandler: completionHandler)
        case .username(let username):
            // fetch username.
            search(forUsersMatching: username) {
                completionHandler($0.flatMap {
                    $0.first.flatMap(Result.success) ?? .failure(GenericError.custom("Invalid response. Processing handler returned `nil`."))
                })
            }
        case .primaryKey(let pk):
            // load user info directly.
            requests.request(User.self,
                             method: .get,
                             endpoint: Endpoint.Users.info.user(pk),
                             process: { User(rawResponse: $0.user) },
                             completion: completionHandler)
        }
    }

    /// Get user's tagged posts.
    public func tagged(user: User.Reference,
                       with paginationParameters: PaginationParameters,
                       updateHandler: PaginationUpdateHandler<Media, AnyPaginatedResponse>?,
                       completionHandler: @escaping PaginationCompletionHandler<Media>) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache), paginationParameters)
            }
            tagged(user: .primaryKey(pk),
                   with: paginationParameters,
                   updateHandler: updateHandler,
                   completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.tagged(user: .primaryKey(user.identity.primaryKey!),
                                   with: paginationParameters,
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error), paginationParameters)
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")), paginationParameters)
                }
            }
        case .primaryKey(let pk):
            // load user tags directly.
            pages.request(Media.self,
                          page: AnyPaginatedResponse.self,
                          with: paginationParameters,
                          endpoint: { Endpoint.UserTags.feed.user(pk).rank(storage.rankToken).next($0.nextMaxId) },
                          splice: { $0.rawResponse.items.array?.compactMap(Media.init) ?? [] },
                          update: updateHandler,
                          completion: completionHandler)
        }
    }

    /// Get `user`'s **followers**.
    public func following(user: User.Reference,
                          usersMatchinQuery query: String? = nil,
                          with paginationParameters: PaginationParameters,
                          updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                          completionHandler: @escaping PaginationCompletionHandler<User>) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache), paginationParameters)
            }
            following(user: .primaryKey(pk),
                      with: paginationParameters,
                      updateHandler: updateHandler,
                      completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.following(user: .primaryKey(user.identity.primaryKey!),
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
            pages.request(User.self,
                          page: AnyPaginatedResponse.self,
                          with: paginationParameters,
                          endpoint: { Endpoint.Friendships.followers.user(pk)
                            .rank(storage.rankToken)
                            .query(query)
                            .next($0.nextMaxId) },
                        splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                        update: updateHandler,
                        completion: completionHandler)
        }
    }

    /// Get  accounts followed by`user` (**following**).
    public func followed(byUser user: User.Reference,
                         usersMatchinQuery query: String? = nil,
                         with paginationParameters: PaginationParameters,
                         updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                         completionHandler: @escaping PaginationCompletionHandler<User>) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")),
                                     paginationParameters)
        }
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache), paginationParameters)
            }
            followed(byUser: .primaryKey(pk),
                     with: paginationParameters,
                     updateHandler: updateHandler,
                     completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased), paginationParameters)
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.followed(byUser: .primaryKey(user.identity.primaryKey!),
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
            pages.request(User.self,
                          page: AnyPaginatedResponse.self,
                          with: paginationParameters,
                          endpoint: { Endpoint.Friendships.folllowing.user(pk)
                            .rank(storage.rankToken)
                            .query(query)
                            .next($0.nextMaxId) },
                        splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                        update: updateHandler,
                        completion: completionHandler)
        }
    }

    /// Get recent activities.
    public func recentActivities(with paginationParameters: PaginationParameters,
                                 updateHandler: PaginationUpdateHandler<SuggestedUser, RecentActivity>?,
                                 completionHandler: @escaping PaginationCompletionHandler<SuggestedUser>) {
            pages.request(SuggestedUser.self,
                          page: RecentActivity.self,
                          with: paginationParameters,
                          endpoint: { Endpoint.News.activities.next($0.nextMaxId) },
                          next: { $0.aymf.nextMaxId.string },
                          splice: { $0.suggestedUsers },
                          update: updateHandler,
                          completion: completionHandler)
    }

    /// Unfollow user.
    public func remove(follower user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot unfollow yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.remove(follower: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .get,
                             endpoint: Endpoint.Friendships.remove.user(pk),
                             body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Approve friendship.
    public func approveRequest(from user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.approveRequest(from: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.approve.user(pk),
                             body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Reject friendship.
    public func rejectRequest(from user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.rejectRequest(from: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.reject.user(pk),
                             body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Get all pending friendship requests.
    public func pendingRequests(with paginationParameters: PaginationParameters,
                                updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                                completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.request(User.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Friendships.pending.next($0.nextMaxId) },
                      splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Follow user.
    public func follow(user: User.Reference, completionHandler: @escaping (Result<Friendship, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.follow(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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
                        "device_id": handler.settings.device.deviceGuid.uuidString]

            requests.request(Friendship.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.follow.user(pk),
                             body: .payload(body),
                             process: { Friendship(rawResponse: $0.friendshipStatus) },
                             completion: completionHandler)
        }
    }

    /// Unfollow user.
    public func unfollow(user: User.Reference, completionHandler: @escaping (Result<Friendship, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.unfollow(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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
                        "device_id": handler.settings.device.deviceGuid.uuidString]

            requests.request(Friendship.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.unfollow.user(pk),
                             body: .payload(body),
                             process: { Friendship(rawResponse: $0.friendshipStatus) },
                             completion: completionHandler)
        }
    }

    /// Friendship status.
    public func friendshipStatus(withUser user: User.Reference, completionHandler: @escaping (Result<Friendship, Error>) -> Void) {
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.friendshipStatus(withUser: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // get status directly.
            requests.request(Friendship.self,
                             method: .get,
                             endpoint: Endpoint.Friendships.status.user(pk),
                             completion: completionHandler)
        }
    }

    /// Friendship statuses.
    /// Use `friendshipStatus(withUser: completionHandler:)` on each and every element of `ids` to retreieve all properties in `Friendship`.
    public func friendshipStatuses<C: Collection>(withUsersMatchingIDs ids: C,
                                                  completionHandler: @escaping(Result<[User.Reference: Friendship], Error>) -> Void)
        where C.Element == Int {
            guard let storage = handler.response?.storage else {
                return completionHandler(.failure(
                    GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")
                ))
            }
            guard !ids.isEmpty else {
                return completionHandler(.failure(GenericError.custom("`ids` must be non-empty.")))
            }

            // get status directly.
            let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                        "include_reel_info": "0",
                        "_csrftoken": storage.csrfToken,
                        "user_ids": Set(ids).map(String.init).joined(separator: ", ")]

            pages.request([User.Reference: Friendship].self,
                          page: AnyPaginatedResponse.self,
                          with: .init(maxPagesToLoad: 1),
                          endpoint: { _ in Endpoint.Friendships.statuses },
                          body: { _ in .parameters(body) },
                          splice: {
                            $0.rawResponse.friendshipStatuses.dictionary?
                                .compactMap { key, value -> [User.Reference: Friendship]? in
                                    guard let primaryKey = Int(key) else { return nil }
                                    return [User.Reference.primaryKey(primaryKey): Friendship(rawResponse: value)]
                                        .compactMapValues { $0 }
                                } ?? []
            },
                        update: nil,
                        completion: { result, _ in
                            completionHandler(result.map {
                                Dictionary(uniqueKeysWithValues: $0.map { $0.map { ($0, $1) } }.joined())
                            })
            })
    }

    /// Get blocked users.
    public func blocked(with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<User, AnyPaginatedResponse>?,
                        completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.request(User.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Users.blocked.next($0.nextMaxId) },
                      splice: { $0.rawResponse.blockedList.array?.compactMap(User.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Block user.
    public func block(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.block(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.block.user(pk),
                             body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        }
    }

    /// Unblock user.
    public func unblock(user: User.Reference, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.unblock(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Friendships.unblock.user(pk),
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
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        switch user {
        case .me:
            completionHandler(.failure(GenericError.custom("You cannot interact with yourself.")))
        case .username:
            // fetch username.
            self.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.report(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
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

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Users.report.user(pk),
                             body: .parameters(body),
                             completion: { completionHandler($0.map { $0.state == .ok }) })
        }
    }
}
