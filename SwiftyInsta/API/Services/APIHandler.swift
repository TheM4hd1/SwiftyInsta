//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol APIHandlerProtocol {
    func login(completion: @escaping (Result<LoginResultModel>) -> ())
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
    
    init(request: RequestMessageModel, user: SessionStorage, device: AndroidDeviceModel, delay: DelayModel, config: URLSessionConfiguration) {
        _delay = delay
        _user = user
        _device = device
        _request = request
        _httpHelper = HttpHelper(config: config)
        _queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    }
    
    func login(completion: @escaping (Result<LoginResultModel>) -> ()) {
        do {
            try _httpHelper.sendRequest(method: .get, url: URLs.getInstagramUrl(), body: [:], header: [:]) { [weak self] (data, response, error) in
                if let error = error {
                    let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: ResponseTypes.unkown)
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
                        do {
                            try self?._httpHelper.sendRequest(method: .post, url: URLs.getLoginUrl(), body: body, header: headers, completion: { (data, response, error) in
                                if let error = error {
                                    let info = ResultInfo.init( error: error, message: error.localizedDescription, responseType: ResponseTypes.unkown)
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
                                                let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .fail)
                                                let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .exception)
                                                completion(result)
                                            }
                                            
                                        } else {
                                            let info = ResultInfo.init(error: CustomErrors.noError, message: CustomErrors.noError.localizedDescription, responseType: ResponseTypes.ok)
                                            let result = Result<LoginResultModel>.init(isSucceeded: true, info: info, value: .success)
                                            completion(result)
                                        }
                                    }
                                }
                            })
                        } catch {
                            let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .fail)
                            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .exception)
                            completion(result)
                        }
                        
                    })
                }
            }
        } catch {
            let info = ResultInfo.init(error: error, message: error.localizedDescription, responseType: .fail)
            let result = Result<LoginResultModel>.init(isSucceeded: false, info: info, value: .exception)
            completion(result)
        }
    }
    
}
