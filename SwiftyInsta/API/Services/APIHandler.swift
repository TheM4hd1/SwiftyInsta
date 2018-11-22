//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol APIHandlerProtocol {
    func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) throws
    func logout(completion: @escaping (Result<Bool>) -> ()) throws
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws
    func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws
    func getUserFollowers(username: String, paginationParameter: PaginationParameters, searchQuery: String, completion: @escaping (Result<[UserShortModel]>) -> ()) throws
    func getUserFollowing(username: String, paginationParameter: PaginationParameters, searchQuery: String, completion: @escaping (Result<[UserShortModel]>) -> ()) throws
    func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws
    func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws
    func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws
    func getUserMedia(for username: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws
    func getMediaInfo(mediaId: String, completion: @escaping (Result<MediaModel>) -> ()) throws
    func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws
    func getRecentActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentActivitiesModel]>) -> ()) throws
    func getRecentFollowingActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentFollowingsActivitiesModel]>) -> ()) throws
    func getDirectInbox(completion: @escaping (Result<DirectInboxModel>) -> ()) throws
    func sendDirect(to userId: String, in threadId: String, with text: String, completion: @escaping (Result<DirectSendMessageResponseModel>) -> ()) throws
    func getDirectThreadById(threadId: String, completion: @escaping (Result<ThreadModel>) -> ()) throws
    func getRecentDirectRecipients(completion: @escaping (Result<RecentRecipientsModel>) -> ()) throws
    func getRankedDirectRecipients(completion: @escaping (Result<RankedRecipientsModel>) -> ()) throws
    func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws
    func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws
    func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws
    func likeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws
    func unLikeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws
    func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws
    func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws
    func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func getUserTags(userId: Int, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws
    func uploadPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws
    func uploadPhotoAlbum(photos: [InstaPhoto], caption: String, completion: @escaping (Result<UploadPhotoAlbumResponse>) -> ()) throws
    func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws
    func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws
}

class APIHandler: APIHandlerProtocol {
    
    private var _delay: DelayModel
    private var _user: SessionStorage
    private var _device: AndroidDeviceModel
    private var _request: RequestMessageModel
    private var _httpHelper: HttpHelper
    private var _queue: DispatchQueue
    private var _twoFactor: TwoFactorLoginInfoModel?
    private var _challenge: ChallengeModel?
    private var _isUserAuthenticated = false
    
    init(request: RequestMessageModel, user: SessionStorage, device: AndroidDeviceModel, delay: DelayModel, config: URLSessionConfiguration) {
        _delay = delay
        _user = user
        _device = device
        _request = request
        _httpHelper = HttpHelper(config: config)
        _queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    }
    
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) throws {
        // validating before login.
        try validateUser()
        try validateRequestMessage()
        
        // Simple 'GET' request to retrieve 'CSRF' token.
        _httpHelper.sendAsync(method: .get, url: try! URLs.getInstagramUrl(), body: [:], header: [:]) { [weak self] (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: ResponseTypes.unknown)
                let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .responseError)
                completion(result)
                
            } else {
                // find CSRF token
                let fields = response?.allHeaderFields
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields as! [String : String], for: (response?.url)!)
                for cookie in cookies {
                    if cookie.name == "csrftoken" {
                        self?._user.csrfToken = cookie.value
                        break
                    }
                }
                
                // Headers
                let headers: [String: String] = [
                    "csrf": (self?._user.csrfToken)!,
                    Headers.HeaderXGoogleADID: (self?._device.googleAdId?.uuidString)!
                ]
                
                // Creating Post Request Body
                let signature = "\(self!._request.generateSignature(signatureKey: Headers.HeaderIGSignatureValue)).\(self!._request.getMessageString())"
                let body: [String: Any] = [
                    Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                    Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
                ]
                
                // Request with delay
                let delay = self!._delay.random()
                self?._queue.asyncAfter(deadline: .now() + delay, execute: {
                    try? self?._httpHelper.sendAsync(method: .post, url: URLs.getLoginUrl(), body: body, header: headers, completion: { (data, response, error) in
                        if let error = error {
                            let info = ResultInfo.init( error: error, message: error.localizedDescription, responseType: ResponseTypes.unknown)
                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .responseError)
                            completion(result)
                            
                        } else {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            
                            if let data = data {
                                if response?.statusCode != 200 {
                                    do {
                                        let loginFailReason = try decoder.decode(LoginBaseResponseModel.self, from: data)
                                        if loginFailReason.invalidCredentials ?? false {
                                            let info = ResultInfo.init(error: CustomErrors.invalidCredentials, message: loginFailReason.message ?? "Invalid Credentials.", responseType: .fail)
                                            let value = (loginFailReason.errorType == "bad_password" ? LoginResultModel.badPassword : LoginResultModel.invalidUser)
                                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: value)
                                            completion(result)
                                            
                                        } else if loginFailReason.twoFactorRequired ?? false {
                                            let info = ResultInfo.init(error: CustomErrors.twoFactorAuthentication, message: loginFailReason.message ?? "Two Factor Authentication is required.", responseType: .fail)
                                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .twoFactorRequired)
                                            self?._twoFactor = loginFailReason.twoFactorInfo
                                            completion(result)
                                            
                                        } else if loginFailReason.checkpointChallengeRequired ?? false {
                                            let info = ResultInfo.init(error: CustomErrors.challengeRequired, message: loginFailReason.message ?? "Challenge is required.", responseType: .fail)
                                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .challengeRequired)
                                            self?._challenge = loginFailReason.challenge
                                            completion(result)
                                        } else {
                                            let info = ResultInfo.init(error: CustomErrors.unExpected(loginFailReason.errorType ?? "unexpected error type."), message: loginFailReason.message ?? "Unexpected error.", responseType: .fail)
                                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .exception)
                                            completion(result)
                                        }
                                    } catch {
                                        fatalError(error.localizedDescription)
                                    }
                                    
                                } else {
                                    do {
                                        let loginInfo = try decoder.decode(LoginResponseModel.self, from: data)
                                        self?._user.loggedInUser = loginInfo.loggedInUser
                                        self?._isUserAuthenticated = (loginInfo.loggedInUser.username?.lowercased() == self?._user.username.lowercased())
                                        self?._user.rankToken = "\(self?._user.loggedInUser.pk ?? 0)_\(self?._request.phoneId ?? "")"
                                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: ResponseTypes.ok)
                                        let result = Result<LoginResultModel>.init(isSucceeded: true, info: info, value: .success)
                                        completion(result)
                                    } catch {
                                        fatalError(error.localizedDescription)
                                    }
                                }
                            }
                        }
                    })
                })
            }
        }
    }
    
    /// Its not working yet.
    func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
        
        _httpHelper.sendAsync(method: .get, url: try URLs.getInstagramUrl(), body: [:], header: [:]) { [weak self] (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                // find CSRF token
                let fields = response?.allHeaderFields
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields as! [String : String], for: (response?.url)!)
                for cookie in cookies {
                    if cookie.name == "csrftoken" {
                        self!._user.csrfToken = cookie.value
                        break
                    }
                }

                let content = [
                    "allow_contacts_sync": "true",
                    "sn_result": "API_ERROR:+null",
                    "phone_id": UUID.init().uuidString,
                    "_csrftoken": self!._user.csrfToken,
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
                    Headers.HeaderXGoogleADID: (self!._device.googleAdId?.uuidString)!
                ]
                
                let delay = 5.0
                self?._queue.asyncAfter(deadline: .now() + delay, execute: {
                    self!._httpHelper.sendAsync(method: .post, url: try! URLs.getCreateAccountUrl(), body: body, header: headers, completion: { (data, response, error) in
                        if let error = error {
                            print("error", error.localizedDescription)
                        } else {
                            if let data = data {
                                //print(response)
                                print(String(data: data, encoding: .utf8)!)
                            }
                        }
                    })
                })
            }
        }
    }
    
    func logout(completion: @escaping (Result<Bool>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getLogoutUrl(), body: [:], header: [:], completion: { [weak self] (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<Bool>.init(isSucceeded: false, info: info, value: false)
                completion(result)
            } else {
                if let data  = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let logoutInfo = try decoder.decode(BaseStatusResponseModel.self, from: data)
                        let message = String(data: data, encoding: String.Encoding.utf8) ?? ""
                        if response?.statusCode != 200 {
                            let info = ResultInfo.init(error: CustomErrors.runTimeError("http error: \(String(describing: response?.statusCode))"), message: message, responseType: .fail)
                            let result = Result<Bool>.init(isSucceeded: false, info: info, value: false)
                            completion(result)
                        } else {
                            if logoutInfo.isOk() {
                                self?._isUserAuthenticated = false
                                let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                                let result = Result<Bool>.init(isSucceeded: true, info: info, value: true)
                                completion(result)
                            }
                        }
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                        let result = Result<Bool>.init(isSucceeded: false, info: info, value: false)
                        completion(result)
                    }
                }
            }
        })
    }
    
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        let headers = [
            Headers.HeaderTimeZoneOffsetKey: Headers.HeaderTimeZoneOffsetValue,
            Headers.HeaderCountKey: Headers.HeaderCountValue,
            Headers.HeaderRankTokenKey: _user.rankToken
        ]
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getUserUrl(username: username), body: [:], header: headers, completion: { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<UserModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
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
                                    let error = CustomErrors.runTimeError("Incorrect pk: \(pk)")
                                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                                    let result = Result<UserModel>.init(isSucceeded: false, info: info, value: nil)
                                    completion(result)
                                } else {
                                    // user found.
                                    let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                                    let result = Result<UserModel>.init(isSucceeded: true, info: info, value: user)
                                    completion(result)
                                }
                            }
                        } else {
                            // Couldn't find the user.
                            let error = CustomErrors.runTimeError("Couldn't find the user: \(username)")
                            let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                            let result = Result<UserModel>.init(isSucceeded: false, info: info, value: nil)
                            completion(result)
                        }
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<UserModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                } else {
                    // nil data.
                    let error = CustomErrors.runTimeError("The data couldn’t be read because it is missing error when decoding JSON.")
                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                    let result = Result<UserModel>.init(isSucceeded: false, info: info, value: nil)
                    completion(result)
                }
            }
        })
    }
    
    func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws {
        // validate before logout.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getUserInfo(id: id), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<UserInfoModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(UserInfoModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<UserInfoModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<UserInfoModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getUserFollowing(username: String, paginationParameter: PaginationParameters, searchQuery: String = "", completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try? getUser(username: username) { [weak self] (user) in
            if user.isSucceeded {
                //var _paginationParameter = paginationParameter
                // - Parameter searchQuery: search for specific username
                let url = try! URLs.getUserFollowing(userPk: user.value?.pk, rankToken: self?._user.rankToken, searchQuery: searchQuery, maxId: paginationParameter.nextId)
                var following: [UserShortModel] = []
                self!.getFollowingList(from: url, completion: { (result) in
                    if result.isSucceeded && result.value?.users != nil {
                        following.append(contentsOf: result.value!.users!)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<[UserShortModel]>.init(isSucceeded: true, info: info, value: following)
                        completion(result)
                    } else {
                        let result = Result<[UserShortModel]>.init(isSucceeded: false, info: result.info, value: nil)
                        completion(result)
                    }
                })
            } else {
                let result = Result<[UserShortModel]>.init(isSucceeded: false, info: user.info, value: nil)
                completion(result)
            }
        }
    }
    
    fileprivate func getFollowingList(from url: URL, completion: @escaping (Result<UserShortListModel>) -> ()) {
        _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<UserShortListModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if response?.statusCode != 200 {
                    let info = ResultInfo.init(error: CustomErrors.runTimeError("http error: \(String(describing: response?.statusCode))"), message: "", responseType: .fail)
                    let result = Result<UserShortListModel>.init(isSucceeded: false, info: info, value: nil)
                    completion(result)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let list = try decoder.decode(UserShortListModel.self, from: data)
                            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                            let result = Result<UserShortListModel>.init(isSucceeded: true, info: info, value: list)
                            completion(result)
                        } catch {
                            let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                            let result = Result<UserShortListModel>.init(isSucceeded: false, info: info, value: nil)
                            completion(result)
                        }
                    } else {
                        let error = CustomErrors.runTimeError("The data couldn’t be read because it is missing error when decoding JSON.")
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<UserShortListModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getUserFollowers(username: String, paginationParameter: PaginationParameters, searchQuery: String, completion: @escaping (Result<[UserShortModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try? getUser(username: username, completion: { [weak self] (user) in
            let url = try! URLs.getUserFollowers(userPk: user.value?.pk, rankToken: self!._user.rankToken, searchQuery: searchQuery, maxId: paginationParameter.nextId)
            var followers: [UserShortModel] = []
            self!.getFollowersList(pk: user.value?.pk, searchQuery: searchQuery, followers: followers, url: url, paginationParameter: paginationParameter, completion: { (result) in
                followers.append(contentsOf: result)
                let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                let result = Result<[UserShortModel]>.init(isSucceeded: true, info: info, value: followers)
                completion(result)
            })
        })
    }
    
    fileprivate func getFollowersList(pk: Int?, searchQuery: String, followers: [UserShortModel], url: URL, paginationParameter: PaginationParameters, completion: @escaping ([UserShortModel]) -> ()) {
        var _paginationParameter = paginationParameter
        _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
            _paginationParameter.pagesLoaded += 1
            if error != nil {
                completion(followers)
            } else {
                if response?.statusCode == 200 {
                    var list = followers
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let decoded = try decoder.decode(UserShortListModel.self, from: data)
                            list.append(contentsOf: decoded.users!)
                            if decoded.bigList! {
                                if !(decoded.nextMaxId?.isEmpty ?? true) && paginationParameter.pagesLoaded <= paginationParameter.maxPagesToLoad {
                                    _paginationParameter.nextId = decoded.nextMaxId ?? ""
                                    let url = try! URLs.getUserFollowers(userPk: pk, rankToken: self!._user.rankToken, searchQuery: searchQuery, maxId: _paginationParameter.nextId)
                                    self!.getFollowersList(pk: pk, searchQuery: searchQuery, followers: list, url: url, paginationParameter: _paginationParameter, completion: { (newusers) in
                                        list.append(contentsOf: newusers)
                                        completion(newusers)
                                    })
                                } else {
                                    completion(list)
                                }
                                
                            } else {
                                completion(list)
                            }
                        } catch {
                            print(error.localizedDescription)
                            completion(list)
                        }
                    }
                } else {
                    completion(followers)
                }
            }
        }
    }
    
    func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(format: "%ld", _user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken
        ]
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getCurrentUser(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<CurrentUserModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let currentUser = try decoder.decode(CurrentUserModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<CurrentUserModel>.init(isSucceeded: true, info: info, value: currentUser)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<CurrentUserModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                } else {
                    let error = CustomErrors.runTimeError("The data couldn’t be read because it is missing error when decoding JSON.")
                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                    let result = Result<CurrentUserModel>.init(isSucceeded: false, info: info, value: nil)
                    completion(result)
                }
            }
        }
    }
    
    func getExploreFeeds(paginationParameter: PaginationParameters, completion: @escaping (Result<[ExploreFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getExploreList(from: try! URLs.getExploreFeedUrl(), exploreList: [], paginationParameter: paginationParameter) { (list) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[ExploreFeedModel]>.init(isSucceeded: true, info: info, value: list)
            completion(result)
        }
    }
    
    fileprivate func getExploreList(from url: URL, exploreList: [ExploreFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([ExploreFeedModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(exploreList)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            var list = exploreList
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if response?.statusCode != 200 {
                        completion(list)
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                let newItems = try decoder.decode(ExploreFeedModel.self, from: data)
                                list.append(newItems)
                                if newItems.moreAvailable! {
                                    _paginationParameter.nextId = newItems.nextMaxId!
                                    let url = try URLs.getExploreFeedUrl(maxId: _paginationParameter.nextId)
                                    self!.getExploreList(from: url, exploreList: list, paginationParameter: _paginationParameter, completion: { (result) in
                                        completion(result)
                                    })
                                } else {
                                    completion(list)
                                }
                            } catch {
                                completion(list)
                            }
                        } else {
                            completion(list)
                        }
                    }
                }
            }
        }
    }
    
    func getUserTimeLine(paginationParameter: PaginationParameters, completion: @escaping (Result<[TimeLineModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getTimeLineList(from: try! URLs.getUserTimeLineUrl(), list: [], paginationParameter: paginationParameter) { (list) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[TimeLineModel]>.init(isSucceeded: true, info: info, value: list)
            completion(result)
        }
    }
    
    fileprivate func getTimeLineList(from url: URL, list: [TimeLineModel], paginationParameter: PaginationParameters, completion: @escaping ([TimeLineModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            var timelineList = list
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(timelineList)
                } else {
                    if response?.statusCode != 200 {
                        completion(timelineList)
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            do {
                                let newItems = try decoder.decode(TimeLineModel.self, from: data)
                                timelineList.append(newItems)
                                if newItems.moreAvailable! {
                                    _paginationParameter.nextId = newItems.nextMaxId!
                                    let url = try URLs.getUserTimeLineUrl(maxId: _paginationParameter.nextId)
                                    self!.getTimeLineList(from: url, list: timelineList, paginationParameter: _paginationParameter, completion: { (result) in
                                        completion(result)
                                    })
                                } else {
                                    completion(timelineList)
                                }
                            } catch {
                                completion(timelineList)
                            }
                        } else {
                            completion(timelineList)
                        }
                    }
                }
            }
        }
    }
    
    func getUserMedia(for username: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        try? getUser(username: username, completion: { [weak self] (result) in
            self!.getMediaList(from: try! URLs.getUserFeedUrl(userPk: result.value?.pk), userPk: result.value?.pk, list: [], paginationParameter: paginationParameter, completion: { (values) in
                let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                let result = Result<[UserFeedModel]>.init(isSucceeded: true, info: info, value: values)
                completion(result)
            })
        })
    }
    
    fileprivate func getMediaList(from url: URL, userPk: Int?, list: [UserFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([UserFeedModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if response?.statusCode != 200 {
                        completion(list)
                    } else {
                        if let data = data {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            var mediaList = list
                            do {
                                let newItems = try decoder.decode(UserFeedModel.self, from: data)
                                mediaList.append(newItems)
                                if newItems.moreAvailable! {
                                    _paginationParameter.nextId = newItems.nextMaxId!
                                    let url = try URLs.getUserFeedUrl(userPk: userPk, maxId: _paginationParameter.nextId)
                                    self!.getMediaList(from: url, userPk: userPk, list: mediaList, paginationParameter: _paginationParameter, completion: { (result) in
                                        completion(result)
                                    })
                                } else {
                                    completion(mediaList)
                                }
                            } catch {
                                completion(list)
                            }
                        } else {
                            completion(list)
                        }
                    }
                }
            }
        }
    }
    
    func getMediaInfo(mediaId: String, completion: @escaping (Result<MediaModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getMediaUrl(mediaId: mediaId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<MediaModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let media = try decoder.decode(UserFeedModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<MediaModel>.init(isSucceeded: true, info: info, value: media.items?.first)
                        completion(result)
                        
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<MediaModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                } else {
                    let error = CustomErrors.runTimeError("The data couldn’t be read because it is missing error when decoding JSON.")
                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                    let result = Result<MediaModel>.init(isSucceeded: false, info: info, value: nil)
                    completion(result)
                }
            }
        }
    }
    
    func getTagFeed(tagName: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[TagFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getTagList(for: try! URLs.getTagFeed(for: tagName), tag: tagName, list: [], paginationParameter: paginationParameter) { (value) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[TagFeedModel]>.init(isSucceeded: true, info: info, value: value)
            completion(result)
        }
    }
    
    fileprivate func getTagList(for url: URL, tag: String, list: [TagFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([TagFeedModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            var tagList = list
                            let newItems = try decoder.decode(TagFeedModel.self, from: data)
                            tagList.append(newItems)
                            if newItems.moreAvailable! {
                                _paginationParameter.nextId = newItems.nextMaxId!
                                let url = try! URLs.getTagFeed(for: tag, maxId: _paginationParameter.nextId)
                                self!.getTagList(for: url, tag: tag, list: tagList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(tagList)
                            }
                        } catch {
                            completion(list)
                        }
                    } else {
                        completion(list)
                    }
                }
            }
        }
    }
    
    func getRecentActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getRecentList(from: try! URLs.getRecentActivities(), list: [], paginationParameter: paginationParameter) { (value) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[RecentActivitiesModel]>.init(isSucceeded: true, info: info, value: value)
            completion(result)
        }
    }
    
    func getRecentFollowingActivities(paginationParameter: PaginationParameters, completion: @escaping (Result<[RecentFollowingsActivitiesModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getRecentFollowingList(from: try! URLs.getRecentFollowingActivities(), list: [], paginationParameter: paginationParameter) { (value) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[RecentFollowingsActivitiesModel]>.init(isSucceeded: true, info: info, value: value)
            completion(result)
        }
    }
    
    fileprivate func getRecentList(from url: URL, list: [RecentActivitiesModel], paginationParameter: PaginationParameters, completion: @escaping ([RecentActivitiesModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        var activitiesList = list
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let newItems = try decoder.decode(RecentActivitiesModel.self, from: data)
                            activitiesList.append(newItems)
                            if (newItems.aymf?.moreAvailable)! {
                                _paginationParameter.nextId = newItems.aymf!.nextMaxId!
                                let url = try! URLs.getRecentActivities(maxId: _paginationParameter.nextId)
                                self!.getRecentList(from: url, list: activitiesList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(activitiesList)
                            }
                        } catch {
                            completion(list)
                        }
                    } else {
                        completion(list)
                    }
                }
            }
        }
    }
    
    fileprivate func getRecentFollowingList(from url: URL, list: [RecentFollowingsActivitiesModel], paginationParameter: PaginationParameters, completion: @escaping ([RecentFollowingsActivitiesModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        var activitiesList = list
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let newItems = try decoder.decode(RecentFollowingsActivitiesModel.self, from: data)
                            activitiesList.append(newItems)
                            if newItems.nextMaxId != nil {
                                _paginationParameter.nextId = String(newItems.nextMaxId!)
                                let url = try! URLs.getRecentFollowingActivities(maxId: _paginationParameter.nextId)
                                self!.getRecentFollowingList(from: url, list: activitiesList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(activitiesList)
                            }
                        } catch {
                            print(error, error.localizedDescription)
                            completion(list)
                        }
                    } else {
                        completion(list)
                    }
                }
            }
        }
    }
    
    func getDirectInbox(completion: @escaping (Result<DirectInboxModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getDirectInbox(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<DirectInboxModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let item = try decoder.decode(DirectInboxModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<DirectInboxModel>.init(isSucceeded: true, info: info, value: item)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                        let result = Result<DirectInboxModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func sendDirect(to userIds: String, in threadIds: String, with text: String, completion: @escaping (Result<DirectSendMessageResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        var content = [
            "text": text,
            "action": "send_item"
        ]
        
        if !userIds.isEmpty {
            content.updateValue("[[\(userIds)]]", forKey: "recipient_users")
        } else {
            throw CustomErrors.runTimeError("Please provide at least one recipient.")
        }
        
        if !threadIds.isEmpty {
            content.updateValue("[\(threadIds)]", forKey: "thread_ids")
        }
        _httpHelper.sendAsync(method: .post, url: try! URLs.getDirectSendTextMessage(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<DirectSendMessageResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(DirectSendMessageResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<DirectSendMessageResponseModel>.init(isSucceeded: false, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<DirectSendMessageResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getDirectThreadById(threadId: String, completion: @escaping (Result<ThreadModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getDirectThread(id: threadId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<ThreadModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if response?.statusCode == 404 {
                        let error = CustomErrors.runTimeError("thread not found.")
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                        let result = Result<ThreadModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    } else {
                        do {
                            let value =  try decoder.decode(ThreadModel.self, from: data)
                            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                            let result = Result<ThreadModel>.init(isSucceeded: true, info: info, value: value)
                            completion(result)
                        } catch {
                            let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                            let result = Result<ThreadModel>.init(isSucceeded: false, info: info, value: nil)
                            completion(result)
                        }
                    }
                }
            }
        }
    }
    
    func getRecentDirectRecipients(completion: @escaping (Result<RecentRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getRecentDirectRecipients(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<RecentRecipientsModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(RecentRecipientsModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<RecentRecipientsModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<RecentRecipientsModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getRankedDirectRecipients(completion: @escaping (Result<RankedRecipientsModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try! URLs.getRankedDirectRecipients(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<RankedRecipientsModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(RankedRecipientsModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<RankedRecipientsModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<RankedRecipientsModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let encoder = JSONEncoder()
        var content = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken
        ]
        
        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        _httpHelper.sendAsync(method: .post, url: try! URLs.setPublicProfile(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(ProfilePrivacyResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let encoder = JSONEncoder()
        var content = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken
        ]
        
        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        _httpHelper.sendAsync(method: .post, url: try! URLs.setPrivateProfile(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(ProfilePrivacyResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<ProfilePrivacyResponseModel>.init(isSucceeded: true, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "old_password": oldPassword,
            "new_password1": newPassword,
            "new_password2": newPassword
        ]
        
        _httpHelper.sendAsync(method: .post, url: try! URLs.getChangePasswordUrl(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<BaseStatusResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(BaseStatusResponseModel.self, from: data)
                        if value.isOk() {
                            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                            let result = Result<BaseStatusResponseModel>.init(isSucceeded: true, info: info, value: value)
                            completion(result)
                        } else {
                            let message = value.message!.errors!.joined(separator: "\n")
                            let info = ResultInfo.init(error: CustomErrors.runTimeError("failed\n for more info see the message propery."), message: message, responseType: .ok)
                            let result = Result<BaseStatusResponseModel>.init(isSucceeded: false, info: info, value: value)
                            completion(result)
                        }
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<BaseStatusResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func likeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "media_id": mediaId
        ]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getLikeMediaUrl(mediaId: mediaId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if response?.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func unLikeMedia(mediaId: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "media_id": mediaId
        ]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getUnLikeMediaUrl(mediaId: mediaId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if response?.statusCode == 200 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getCommentList(for: try URLs.getComments(for: mediaId), mediaId: mediaId, list: [], paginationParameter: paginationParameter) { (value) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[MediaCommentsResponseModel]>.init(isSucceeded: true, info: info, value: value)
            completion(result)
        }
    }
    
    fileprivate func getCommentList(for url: URL, mediaId: String, list: [MediaCommentsResponseModel], paginationParameter: PaginationParameters, completion: @escaping ([MediaCommentsResponseModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        var commentList = list
                        do {
                            let newItem = try decoder.decode(MediaCommentsResponseModel.self, from: data)
                            commentList.append(newItem)
                            if newItem.hasMoreComments! && newItem.nextMaxId != nil {
                                _paginationParameter.nextId = newItem.nextMaxId!
                                let url = try! URLs.getComments(for: mediaId, maxId: _paginationParameter.nextId)
                                self!.getCommentList(for: url, mediaId: mediaId, list: commentList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(commentList)
                            }
                        } catch {
                            completion(list)
                        }
                    }
                }
            }
        }
    }
    
    func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getFollowUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getUnFollowUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        _httpHelper.sendAsync(method: .get, url: try URLs.getFriendshipStatusUrl(for: userId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<FriendshipStatusModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FriendshipStatusModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<FriendshipStatusModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<FriendshipStatusModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        _httpHelper.sendAsync(method: .post, url: try URLs.getBlockUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let body = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "user_id": String(userId),
            "radio_type": "wifi-none"
        ]
        _httpHelper.sendAsync(method: .post, url: try URLs.getUnBlockUrl(for: userId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(FollowResponseModel.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: true, info: info, value: value)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<FollowResponseModel>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func getUserTags(userId: Int, paginationParameter: PaginationParameters, completion: @escaping (Result<[UserFeedModel]>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        userTagsList(from: try URLs.getUserTagsUrl(userPk: userId, rankToken: _user.rankToken), userId: userId, rankToken: _user.rankToken, list: [], paginationParameter: paginationParameter) { (value) in
            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
            let result = Result<[UserFeedModel]>.init(isSucceeded: true, info: info, value: value)
            completion(result)
        }
    }
    
    fileprivate func userTagsList(from url: URL, userId: Int, rankToken: String, list: [UserFeedModel], paginationParameter: PaginationParameters, completion: @escaping ([UserFeedModel]) -> ())
    {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            _httpHelper.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        var usertagsList = list
                        do {
                            let newItems = try decoder.decode(UserFeedModel.self, from: data)
                            usertagsList.append(newItems)
                            if newItems.moreAvailable! {
                                _paginationParameter.nextId = newItems.nextMaxId!
                                let url = try! URLs.getUserTagsUrl(userPk: userId, rankToken: rankToken, maxId: _paginationParameter.nextId)
                                self!.userTagsList(from: url, userId: userId, rankToken: rankToken, list: usertagsList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(usertagsList)
                            }
                        } catch {
                            print(error, error.localizedDescription)
                            completion(list)
                        }
                    } else {
                        completion(list)
                    }
                }
            }
        }
    }
    
    func uploadPhoto(photo: InstaPhoto, completion: @escaping (Result<UploadPhotoResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let uploadId = _request.generateUploadId()
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
        content.append(string: "\(uploadId)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
        content.append(string: "\(_device.deviceGuid.uuidString)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
        content.append(string: "\(_user.csrfToken)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
        content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Transfer-Encoding: binary\n")
        content.append(string: "Content-Type: application/octet-stream\n")
        content.append(string: "Content-Disposition: form-data; name=photo; filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n")
        
        let imageData = photo.image.jpegData(compressionQuality: 1)
        
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")

        let header = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getUploadPhotoUrl(), body: [:], header: header, data: content) { [weak self] (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<UploadPhotoResponse>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let res = try decoder.decode(UploadPhotoResponse.self, from: data)
                        if res.status! == "ok" {
                            self!.configureMedia(photo: photo, uploadId: uploadId, caption: photo.caption, completion: { (media, error) in
                                if let error = error {
                                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                                    let result = Result<UploadPhotoResponse>.init(isSucceeded: false, info: info, value: nil)
                                    completion(result)
                                } else {
                                    let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                                    let result = Result<UploadPhotoResponse>.init(isSucceeded: true, info: info, value: media)
                                    completion(result)
                                }
                            })
                        } else {
                            let info = ResultInfo.init(error: CustomErrors.runTimeError("fail"), message: res.status!, responseType: .ok)
                            let result = Result<UploadPhotoResponse>.init(isSucceeded: false, info: info, value: nil)
                            completion(result)
                        }
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    fileprivate func configureMedia(photo: InstaPhoto, uploadId: String, caption: String, completion: @escaping (UploadPhotoResponse?, Error?) -> ()) {
        let url = try! URLs.getConfigureMediaUrl()
        let version = _device.frimwareFingerprint.split(separator: "/")[2].split(separator: ":")[1]
        let androidVersion = AndroidVersion.fromString(versionString: String(version))
        if let androidVersion = androidVersion {
            let configureDevice = ConfigureDevice.init(manufacturer: _device.hardwareManufacturer, model: _device.hardwareModel, android_version: androidVersion.versionNumber, android_release: androidVersion.apiLevel)
            let configureEdits = ConfigureEdits.init(crop_original_size: [photo.width, photo.height], crop_center: [0.0, -0.0], crop_zoom: 1)
            let configureExtras = ConfigureExtras.init(source_width: photo.width, source_height: photo.height)
            let configure = ConfigurePhotoModel.init(_uuid: _device.deviceGuid.uuidString, _uid: _user.loggedInUser.pk!, _csrftoken: _user.csrfToken, media_folder: "Camera", source_type: "4", caption: caption, upload_id: uploadId, device: configureDevice, edits: configureEdits, extras: configureExtras)
            
            let encoder = JSONEncoder()
            let payload = String(data: try! encoder.encode(configure), encoding: .utf8)!
            let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
            // Creating Post Request Body
            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
            ]
            
            _httpHelper.sendAsync(method: .post, url: url, body: body, header: [:]) { (data, response, error) in
                if error != nil {
                    completion(nil, error)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let media = try decoder.decode(UploadPhotoResponse.self, from: data)
                            completion(media, nil)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, CustomErrors.runTimeError("no data received from server."))
                    }
                }
            }
        } else {
            completion(nil, CustomErrors.runTimeError("Unsupported android version"))
        }
    }
    
    func uploadPhotoAlbum(photos: [InstaPhoto], caption: String, completion: @escaping (Result<UploadPhotoAlbumResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        getUploadIdsForPhotoAlbum(uploadIds: [], photos: photos) { [weak self] (uploadIds) in
            self!.configureMediaAlbum(uploadIds: uploadIds, caption: caption, completion: { (value, error) in
                if let error = error {
                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                    let result = Result<UploadPhotoAlbumResponse>.init(isSucceeded: false, info: info, value: nil)
                    completion(result)
                } else {
                    let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                    let result = Result<UploadPhotoAlbumResponse>.init(isSucceeded: true, info: info, value: value)
                    completion(result)
                }
            })
        }
    }
    
    fileprivate func getUploadIdsForPhotoAlbum(uploadIds: [String], photos: [InstaPhoto], completion: @escaping ([String]) -> ()) {
        if photos.count == 0 {
            completion(uploadIds)
        } else {
            var _uploadIds = uploadIds
            var _photos = photos
            let _currentPhoto = _photos.removeFirst()
            
            let uploadId = _request.generateUploadId()
            var content = Data()
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Type: text/plain; charset=utf-8\n")
            content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
            content.append(string: "\(uploadId)\n")
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Type: text/plain; charset=utf-8\n")
            content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
            content.append(string: "\(_device.deviceGuid.uuidString)\n")
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Type: text/plain; charset=utf-8\n")
            content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
            content.append(string: "\(_user.csrfToken)\n")
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Type: text/plain; charset=utf-8\n")
            content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
            content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Type: text/plain; charset=utf-8\n")
            content.append(string: "Content-Disposition: form-data; name=\"is_sidecar\"\n\n")
            content.append(string: "1\n")
            content.append(string: "--\(uploadId)\n")
            content.append(string: "Content-Transfer-Encoding: binary\n")
            content.append(string: "Content-Type: application/octet-stream\n")
            content.append(string: "Content-Disposition: form-data; name=photo; filename=pending_media_\(uploadId).jpg; filename*=utf-8''pending_media_\(uploadId).jpg\n\n")
            
            let imageData = _currentPhoto.image.jpegData(compressionQuality: 1)
            
            content.append(imageData!)
            content.append(string: "\n--\(uploadId)--\n\n")
            
            let header = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
            
            _httpHelper.sendAsync(method: .post, url: try! URLs.getUploadPhotoUrl(), body: [:], header: header, data: content) { [weak self] (data, response, error) in
                if error != nil {
                    completion(_uploadIds)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let res = try decoder.decode(UploadPhotoResponse.self, from: data)
                            if res.status! == "ok" {
                                _uploadIds.append(res.uploadId!)
                                self!.getUploadIdsForPhotoAlbum(uploadIds: _uploadIds, photos: _photos, completion: { (ids) in
                                    completion(ids)
                                })
                            } else {
                                completion(_uploadIds)
                            }
                        } catch {
                            completion(_uploadIds)
                        }
                    } else {
                        completion(_uploadIds)
                    }
                }
            }
            
        }
    }
    
    fileprivate func configureMediaAlbum(uploadIds: [String], caption: String, completion: @escaping (UploadPhotoAlbumResponse?, Error?) -> ()) {
        let url = try! URLs.getConfigureMediaAlbumUrl()
        let clientSidecarId = _request.generateUploadId()
        
        var childrens: [ConfigureChildren] = []
        for id in uploadIds {
            childrens.append(ConfigureChildren.init(scene_capture_type: "standard", mas_opt_in: "NOT_PROMPTED", camera_position: "unknown", allow_multi_configures: false, geotag_enabled: false, disable_comments: false, source_type: 0, upload_id: id))
        }
        
        let content = ConfigurePhotoAlbumModel.init(_uuid: _device.deviceGuid.uuidString, _uid: _user.loggedInUser.pk!, _csrftoken: _user.csrfToken, caption: caption, client_sidecar_id: clientSidecarId, geotag_enabled: false, disable_comments: false, children_metadata: childrens)
        
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        // Creating Post Request Body
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        _httpHelper.sendAsync(method: .post, url: url, body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let res = try decoder.decode(UploadPhotoAlbumResponse.self, from: data)
                        completion(res, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let content = [
            "user_breadcrumb": String(Date().millisecondsSince1970),
            "idempotence_token": UUID.init().uuidString,
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken,
            "comment_text": text,
            "containermodule": "comments_feed_timeline",
            "radio_type": "wifi-none"
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
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getPostCommentUrl(mediaId: mediaId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .unknown)
                let result = Result<CommentResponse>.init(isSucceeded: false, info: info, value: nil)
                completion(result)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let res = try decoder.decode(CommentResponse.self, from: data)
                        let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: .ok)
                        let result = Result<CommentResponse>.init(isSucceeded: true, info: info, value: res)
                        completion(result)
                    } catch {
                        let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .ok)
                        let result = Result<CommentResponse>.init(isSucceeded: false, info: info, value: nil)
                        completion(result)
                    }
                }
            }
        }
    }
    
    func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws {
        // validate before request.
        try validateUser()
        try validateLoggedIn()
        
        let content = [
            "_uuid": _device.deviceGuid.uuidString,
            "_uid": String(_user.loggedInUser.pk!),
            "_csrftoken": _user.csrfToken
        ]
        
        _httpHelper.sendAsync(method: .post, url: try URLs.getDeleteCommentUrl(mediaId: mediaId, commentId: commentPk), body: content, header: [:]) { (data, response, error) in
            if error != nil {
                completion(false)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let status = try? decoder.decode(BaseStatusResponseModel.self, from: data)
                    completion(status!.isOk())
                }
            }
        }
    }
    
    fileprivate func validateUser() throws {
        if _user.username.isEmpty || _user.password.isEmpty {
            throw CustomErrors.runTimeError("username and password must be specified.")
        }
    }
    
    fileprivate func validateLoggedIn() throws {
        if !_isUserAuthenticated {
            throw CustomErrors.runTimeError("user must be authenticated.")
        }
    }
    
    fileprivate func validateRequestMessage() throws {
        if _request.isEmpty() {
            throw CustomErrors.runTimeError("empty request message.")
        }
    }
}

