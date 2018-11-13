//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol APIHandlerProtocol {
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) throws
    func logout(completion: @escaping (Result<Bool>) -> ()) throws
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws
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

