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
    // MARK: Authentication
    func authenticate(cache: SessionCache, completionHandler: @escaping (Result<Login.Response, Error>) -> Void) {
        // update handler.
        handler.settings.device = cache.device
        handler.response = .init(model: .pending, cache: cache)
        // fetch the user.
        getCurrentUser { [weak self] in
            switch $0 {
            case .success(let model):
                // update user info alone.
                if let user = model.user { self?.handler.response?.cache?.storage?.user = user }
                completionHandler(.success(.init(model: .success, cache: cache)))
            case .failure(let error): completionHandler(.failure(error))
            }
        }
    }
    
    func logOut(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard handler.user != nil else {
            return handler.settings.queues.response.async {
                completionHandler(.failure(CustomErrors.runTimeError("User is not logged in.")))
            }
        }
        handler.requests.sendAsync(method: .post, url: try! URLs.getLogoutUrl()) { [weak self] in
            guard let handler = self?.handler else { return completionHandler(.failure(CustomErrors.weakReferenceReleased)) }
            let result = $0.flatMap { data, response -> Result<Bool, Error> in
                do {
                    guard let data = data, response?.statusCode == 200 else { throw CustomErrors.runTimeError("Invalid response.") }
                    // decode data.
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(BaseStatusResponseModel.self, from: data)
                    return .success(decoded.isOk())
                } catch { return .failure(error) }
            }
            handler.settings.queues.response.async { completionHandler(result) }
        }
    }

    // MARK: Endpoints
    public func getCurrentUser(completionHandler: @escaping (Result<CurrentUserModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken]
        
        requests.decodeAsync(CurrentUserModel.self,
                             method: .get,
                             url: try! URLs.getCurrentUser(),
                             body: .parameters(body),
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
                let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
                // Creating Post Request Body
                let signature = "\(hash).\(payload)"
                let body: [String: Any] = [
                    Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                    Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
                ]
                
                let headers: [String: String] = [
                    "X-IG-App-ID": "567067343352427",
                    Headers.HeaderXGoogleADID: (HandlerSettings.shared.device!.googleAdId?.uuidString)!
                ]
                
                guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
                httpHelper.sendAsync(method: .post, url: try! URLs.getCreateAccountUrl(), body: body, header: headers, completion: { (data, response, error) in
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
    }
        
    func searchUser(username: String, completion: @escaping (InstagramResult<[UserModel]>) -> ()) throws {
        let headers = [
            Headers.HeaderTimeZoneOffsetKey: Headers.HeaderTimeZoneOffsetValue,
            Headers.HeaderCountKey: Headers.HeaderCountValue,
            Headers.HeaderRankTokenKey: HandlerSettings.shared.user!.rankToken
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getUserUrl(username: username), body: [:], header: headers, completion: { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let info = try decoder.decode(SearchUserModel.self, from: data)
                        if let users = info.users {
                            completion(Return.success(value: users))
                        } else {
                            // Couldn't find the user.
                            let error = CustomErrors.unExpected("Couldn't find the user: \(username)")
                            completion(Return.fail(error: error, response: .ok, value: nil))                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    // nil data.
                    let error = CustomErrors.unExpected("The data couldn’t be read because it is missing error when decoding JSON.")
                    completion(Return.fail(error: error, response: .ok, value: nil))
                }
            }
        })
    }
    
    func getUser(username: String, completion: @escaping (InstagramResult<UserModel>) -> ()) throws {
        let headers = [
            Headers.HeaderTimeZoneOffsetKey: Headers.HeaderTimeZoneOffsetValue,
            Headers.HeaderCountKey: Headers.HeaderCountValue,
            Headers.HeaderRankTokenKey: HandlerSettings.shared.user!.rankToken
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getUserUrl(username: username), body: [:], header: headers, completion: { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let info = try decoder.decode(SearchUserModel.self, from: data)
                        if let user = info.users?.first {
                            if let pk = user.pk {
                                if pk < 1 {
                                    // Incorrect pk.
                                    let error = CustomErrors.unExpected("Incorrect pk: \(pk)")
                                    completion(Return.fail(error: error, response: .ok, value: nil))
                                } else {
                                    // user found.
                                    completion(Return.success(value: user))                                }
                            }
                        } else {
                            // Couldn't find the user.
                            let error = CustomErrors.unExpected("Couldn't find the user: \(username)")
                            completion(Return.fail(error: error, response: .ok, value: nil))                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    // nil data.
                    let error = CustomErrors.unExpected("The data couldn’t be read because it is missing error when decoding JSON.")
                    completion(Return.fail(error: error, response: .ok, value: nil))
                }
            }
        })
    }
    
    func getUser(id: Int, completion: @escaping (InstagramResult<UserInfoModel>) -> ()) throws {
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getUserInfo(id: id), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(UserInfoModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func getUserTags(user: UserReference,
                     paginationParameters: PaginationParameters,
                     updateHandler: PaginationResponse<UserFeedModel>?,
                     completionHandler: @escaping PaginationResponse<InstagramResult<[UserFeedModel]>>) throws {
        switch user {
        case .username(let username):
            // fetch username.
            try UserHandler.shared.getUser(username: username) { [weak self] in
                try? self?.getUserTags(user: .pk($0.value?.pk ?? 0),
                                       paginationParameters: paginationParameters,
                                       updateHandler: updateHandler,
                                       completionHandler: completionHandler)
            }
        case .pk(let pk):
            // load user media directly.
            PaginationHelper.getPages(UserFeedModel.self,
                                       for: paginationParameters,
                                       at: { try URLs.getUserTagsUrl(userPk: pk, rankToken: HandlerSettings.shared.user!.rankToken, maxId: $0.nextMaxId ?? "") },
                                       updateHandler: updateHandler,
                                       completionHandler: completionHandler)
        }
    }
        
    func getUserFollowing(user: UserReference,
                          filteringProfilesMatchingQuery query: String? = nil,
                          paginationParameters: PaginationParameters,
                          updateHandler: PaginationResponse<UserShortListModel>?,
                          completionHandler: @escaping PaginationResponse<InstagramResult<[UserShortModel]>>) throws {
        switch user {
        case .username(let username):
            // fetch username.
            try UserHandler.shared.getUser(username: username) { [weak self] in
                try? self?.getUserFollowing(user: .pk($0.value?.pk ?? 0),
                                            filteringProfilesMatchingQuery: query,
                                            paginationParameters: paginationParameters,
                                            updateHandler: updateHandler,
                                            completionHandler: completionHandler)
            }
        case .pk(let pk):
            // load user info directly.
            PaginationHelper.getPages(UserShortListModel.self,
                                       for: paginationParameters,
                                       at: { try URLs.getUserFollowing(userPk: pk,
                                                                       rankToken: HandlerSettings.shared.user!.rankToken,
                                                                       searchQuery: query ?? "",
                                                                       maxId: $0.nextMaxId ?? "") },
                                       updateHandler: updateHandler,
                                       completionHandler: { response, parameters in
                                        let users = response.value?.reduce([]) { $0+($1.users ?? []) }
                                        completionHandler(Result(isSucceeded: response.isSucceeded,
                                                                 info: response.info,
                                                                 value: users),
                                                          parameters)
            })
        }
    }

    func getUserFollowers(user: UserReference,
                          filteringProfilesMatchingQuery query: String?,
                          paginationParameters: PaginationParameters,
                          updateHandler: PaginationResponse<UserShortListModel>?,
                          completionHandler: @escaping PaginationResponse<InstagramResult<[UserShortModel]>>) throws {
        switch user {
        case .username(let username):
            // fetch username.
            try UserHandler.shared.getUser(username: username) { [weak self] in
                try? self?.getUserFollowers(user: .pk($0.value?.pk ?? 0),
                                            filteringProfilesMatchingQuery: query,
                                            paginationParameters: paginationParameters,
                                            updateHandler: updateHandler,
                                            completionHandler: completionHandler)
            }
        case .pk(let pk):
            // load user info directly.
            PaginationHelper.getPages(UserShortListModel.self,
                                       for: paginationParameters,
                                       at: { try URLs.getUserFollowers(userPk: pk,
                                                                       rankToken: HandlerSettings.shared.user!.rankToken,
                                                                       searchQuery: query ?? "",
                                                                       maxId: $0.nextMaxId ?? "") },
                                       updateHandler: updateHandler,
                                       completionHandler: { response, parameters in
                                        let users = response.value?.reduce([]) { $0+($1.users ?? []) }
                                        completionHandler(Result(isSucceeded: response.isSucceeded,
                                                                 info: response.info,
                                                                 value: users),
                                                          parameters)
            })
        }
    }
    
    func getRecentActivities(paginationParameters: PaginationParameters,
                             updateHandler: PaginationResponse<RecentActivitiesModel>?,
                             completionHandler: @escaping PaginationResponse<InstagramResult<[RecentActivitiesModel]>>) throws {
        PaginationHelper.getPages(RecentActivitiesModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getRecentActivities(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }

    func getRecentFollowingActivities(paginationParameters: PaginationParameters,
                                      updateHandler: PaginationResponse<RecentFollowingsActivitiesModel>?,
                                      completionHandler: @escaping PaginationResponse<InstagramResult<[RecentFollowingsActivitiesModel]>>) throws {
        PaginationHelper.getPages(RecentFollowingsActivitiesModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getRecentFollowingActivities(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }
    
    func removeFollower(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.removeFollowerUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func approveFriendship(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.approveFriendshipUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func rejectFriendship(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.rejectFriendshipUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func pendingFriendships(completion: @escaping (InstagramResult<PendingFriendshipsModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.pendingFriendshipsUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(PendingFriendshipsModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func followUser(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getFollowUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func unFollowUser(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getUnFollowUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func getFriendshipStatus(of userId: Int, completion: @escaping (InstagramResult<FriendshipStatusModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getFriendshipStatusUrl(for: userId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FriendshipStatusModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func getFriendshipStatuses(of userIds: [Int], completion: @escaping (InstagramResult<FriendshipStatusesModel>) -> ()) throws {
        
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
    }
    
    func getBlockedList(completion: @escaping (InstagramResult<BlockedUsersModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getBlockedList(), body: [:], header: [:]) { (data, res, err) in
            if let error = err {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(BlockedUsersModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func block(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getBlockUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func unBlock(userId: Int, completion: @escaping (InstagramResult<FollowResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getUnBlockUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
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
                httpHelper.sendAsync(method: .post, url: try! URLs.getRecoverByEmailUrl(), body: body, header: [:], completion: { (data, response, error) in
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
    }
    
    func reportUser(userPk: Int, completion: @escaping (InstagramResult<Bool>) -> ()) throws {
        let url = try URLs.reportUserUrl(userPk: userPk)
        guard let handler = HandlerSettings.shared.httpHelper else { return }
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "user_id": String(userPk),
            "source_name": "profile",
            "is_spam": "true",
            "reason_id": "1"
        ]
        
        handler.sendAsync(method: .post, url: url, body: body, header: [:], completion: { (data, res, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: false))
            } else {
                if res?.statusCode == 200 {
                    completion(Return.success(value: true))
                } else {
                    completion(Return.fail(error: nil, response: .wrongRequest, value: false))
                }
            }
        })
    }*/
}
