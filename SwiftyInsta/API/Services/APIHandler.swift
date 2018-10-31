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
        do {
            try validateUser()
            try validateRequestMessage()
        } catch let error as CustomErrors {
            throw CustomErrors.runTimeError(error.localizedDescription)
        }
        
        // Simple 'GET' request to retrieve 'CSRF' token.
        try? _httpHelper.sendRequest(method: .get, url: URLs.getInstagramUrl(), body: [:], header: [:]) { [weak self] (data, response, error) in
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
                    try? self?._httpHelper.sendRequest(method: .post, url: URLs.getLoginUrl(), body: body, header: headers, completion: { (data, response, error) in
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
        do {
            try validateUser()
            try validateLoggedIn()
        } catch let error as CustomErrors {
            throw CustomErrors.runTimeError(error.localizedDescription)
        }
        
        try? _httpHelper.sendRequest(method: .get, url: URLs.getLogoutUrl(), body: [:], header: [:], completion: { [weak self] (data, response, error) in
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
        do {
            try validateUser()
            try validateLoggedIn()
        } catch let error as CustomErrors {
            throw CustomErrors.runTimeError(error.localizedDescription)
        }
        
        let headers = [
            Headers.HeaderTimeZoneOffsetKey: Headers.HeaderTimeZoneOffsetValue,
            Headers.HeaderCountKey: Headers.HeaderCountValue,
            Headers.HeaderRankTokenKey: _user.rankToken
        ]
        
        try? _httpHelper.sendRequest(method: .get, url: URLs.getUserUrl(username: username), body: [:], header: headers, completion: { (data, response, error) in
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

