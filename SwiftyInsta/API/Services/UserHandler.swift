//
//  UserHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum UserReference {
    case pk(Int)
    case username(String)
}

public protocol UserHandlerProtocol {
    func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws
    func login(completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws
    func login(cache: SessionCache, completion: @escaping (Result<LoginResultModel>) -> ()) throws
    func twoFactorLogin(verificationCode: String, useBackupCode: Bool, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws
    func sendTwoFactorLoginSms(completion: @escaping (Result<Bool>) -> ()) throws
    func challengeLogin(completion: @escaping (Result<ResponseTypes>) -> ()) throws
    func verifyMethod(of type: VerifyTypes, completion: @escaping (Result<VerifyResponse>) ->()) throws
    func sendVerifyCode(securityCode: String, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws
    func logout(completion: @escaping (Result<Bool>) -> ()) throws
    func searchUser(username: String, completion: @escaping (Result<[UserModel]>) -> ()) throws
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws
    func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws
    func getUserTags(user: UserReference,
                     paginationParameters: PaginationParameters,
                     updateHandler: PaginationResponse<UserFeedModel>?,
                     completionHandler: @escaping PaginationResponse<Result<[UserFeedModel]>>) throws
    func getUserFollowing(user: UserReference,
                          filteringProfilesMatchingQuery query: String?,
                          paginationParameters: PaginationParameters,
                          updateHandler: PaginationResponse<UserShortListModel>?,
                          completionHandler: @escaping PaginationResponse<Result<[UserShortModel]>>) throws
    func getUserFollowers(user: UserReference,
                          filteringProfilesMatchingQuery query: String?,
                          paginationParameters: PaginationParameters,
                          updateHandler: PaginationResponse<UserShortListModel>?,
                          completionHandler: @escaping PaginationResponse<Result<[UserShortModel]>>) throws
    func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws
    func getRecentActivities(paginationParameters: PaginationParameters,
                             updateHandler: PaginationResponse<RecentActivitiesModel>?,
                             completionHandler: @escaping PaginationResponse<Result<[RecentActivitiesModel]>>) throws
    func getRecentFollowingActivities(paginationParameters: PaginationParameters,
                                      updateHandler: PaginationResponse<RecentFollowingsActivitiesModel>?,
                                      completionHandler: @escaping PaginationResponse<Result<[RecentFollowingsActivitiesModel]>>) throws
    func removeFollower(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func approveFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func rejectFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func pendingFriendships(completion: @escaping (Result<PendingFriendshipsModel>) -> ()) throws
    func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws
    func getFriendshipStatuses(of userIds: [Int], completion: @escaping (Result<FriendshipStatusesModel>) -> ()) throws
    func getBlockedList(completion: @escaping (Result<BlockedUsersModel>) -> ()) throws
    func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws
    func recoverAccountBy(email: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws
    func recoverAccountBy(username: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws
    func reportUser(userPk: Int, completion: @escaping (Result<Bool>) -> ()) throws
}

class UserHandler: UserHandlerProtocol {
    
    static let shared = UserHandler()

    private init() {}
    
    
    func login(cache: SessionCache, completion: @escaping (Result<LoginResultModel>) -> ()) throws {
        if cache.isUserAuthenticated {
            HandlerSettings.shared.isUserAuthenticated = cache.isUserAuthenticated
            HandlerSettings.shared.device = cache.device
            HandlerSettings.shared.user = cache.user
            HandlerSettings.shared.request = cache.requestMessage
            HandlerSettings.shared.httpHelper?.setCookies(cache.cookies)
            
            try getCurrentUser { (result) in
                if result.isSucceeded {
                    completion(Return.success(value: .success))
                } else {
                    completion(Return.fail(error: result.info.error, response: ResponseTypes.fail, value: nil))
                }
            }
        } else {
            throw CustomErrors.runTimeError("bad cache info.")
        }
    }
    
    func login(completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        // sending a 'GET' request to retrieve 'CSRF' token.
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getInstagramUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .unknown, value: nil), nil)
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
            
                let headers = [
                    "csrf": (HandlerSettings.shared.user!.csrfToken),
                    Headers.HeaderXGoogleADID: (HandlerSettings.shared.device!.googleAdId?.uuidString)!
                ]
                
                // Creating Post Request Body
                let signature = "\(HandlerSettings.shared.request!.generateSignature(signatureKey: Headers.HeaderIGSignatureValue)).\(HandlerSettings.shared.request!.getMessageString())"
                
                let body: [String: Any] = [
                    Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!,
                    Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
                ]
                
                // send login request
                guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
                httpHelper.sendAsync(method: .post, url: try! URLs.getLoginUrl(), body: body, header: headers, completion: { (data, response, error) in
                    if let error = error {
                        completion(Return.fail(error: error, response: .unknown, value: nil), nil)
                    } else {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        if let data = data {
                            print(String(data: data, encoding: .utf8)!)
                            if response?.statusCode != 200 {
                                do {
                                    var loginFailReason = try decoder.decode(LoginBaseResponseModel.self, from: data)
                                    if loginFailReason.errorType == nil {
                                        loginFailReason.errorType = ""
                                    }
                                    guard let errorType = loginFailReason.errorType else { return }
                                    if loginFailReason.invalidCredentials ?? false || errorType == "bad_password" {
                                        let value = (errorType == "bad_password" ? LoginResultModel.badPassword : LoginResultModel.invalidUser)
                                        completion(Return.fail(error: CustomErrors.invalidCredentials, response: .fail, value: value), nil)
                                        
                                    } else if loginFailReason.twoFactorRequired ?? false {
                                        HandlerSettings.shared.twoFactor = loginFailReason.twoFactorInfo
                                        
                                        if loginFailReason.twoFactorInfo?.totpTwoFactorOn == true {
                                            completion(Return.fail(error: CustomErrors.twoFactorAuthentication, response: .totp, value: .twoFactorRequired), nil)
                                        } else {
                                            completion(Return.fail(error: CustomErrors.twoFactorAuthentication, response: .sms(obfuscatedPhoneNumber: loginFailReason.twoFactorInfo!.obfuscatedPhoneNumber), value: .twoFactorRequired), nil)
                                        }
                                        
                                    } else if loginFailReason.checkpointChallengeRequired ?? false || errorType == "checkpoint_challenge_required" {
                                        HandlerSettings.shared.challenge = loginFailReason.challenge
                                        completion(Return.fail(error: CustomErrors.challengeRequired, response: .ok, value: .challengeRequired), nil)
                                    } else {
                                        completion(Return.fail(error: CustomErrors.unExpected(loginFailReason.errorType ?? "unexpected error type."), response: .ok, value: .exception), nil)
                                    }
                                } catch {
                                    completion(Return.fail(error: error, response: .ok, value: nil), nil)
                                }
                                
                            } else {
                                do {
                                    let loginInfo = try decoder.decode(LoginResponseModel.self, from: data)
                                    HandlerSettings.shared.user!.loggedInUser = loginInfo.loggedInUser
                                    HandlerSettings.shared.isUserAuthenticated = (loginInfo.loggedInUser.username?.lowercased() == HandlerSettings.shared.user!.username.lowercased())
                                    HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
                                    
                                    let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)
                                    completion(Return.success(value: .success), sessionCache)
                                } catch {
                                    completion(Return.fail(error: error, response: .ok, value: nil), nil)
                                }
                            }
                        }
                    }
                })
            }
        }
    }
    
    private func getTwoFactorLoginRequestBody(verificationCode: String, verificationMethod: String) -> [String: Any] {
        let content = [
            "verification_code": verificationCode,
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "two_factor_identifier" : HandlerSettings.shared.twoFactor!.twoFactorIdentifier,
            "username": HandlerSettings.shared.user!.username,
            "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "device_id":  RequestMessageModel.generateDeviceIdFromGuid(guid: HandlerSettings.shared.device!.deviceGuid),
            "verification_method": verificationMethod
        ]
        
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        return body
    }
    
    func twoFactorLogin(verificationCode: String, useBackupCode: Bool, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        var verificationMethod = TwoFactorVerificationMethodsEnum.none.rawValue
        
        if useBackupCode {
            verificationMethod = TwoFactorVerificationMethodsEnum.backup.rawValue
        } else if HandlerSettings.shared.twoFactor?.totpTwoFactorOn == true {
            verificationMethod = TwoFactorVerificationMethodsEnum.totp.rawValue
        } else if HandlerSettings.shared.twoFactor?.smsTwoFactorOn == true {
            verificationMethod = TwoFactorVerificationMethodsEnum.sms.rawValue
        }
        
        let body = getTwoFactorLoginRequestBody(verificationCode: verificationCode, verificationMethod: verificationMethod)
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getTwoFactorLoginUrl(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .unknown, value: nil), nil)
            } else {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let data = data {
                    if response?.statusCode != 200 {
                        do {
                            var loginFailReason = try decoder.decode(LoginBaseResponseModel.self, from: data)
                            if loginFailReason.errorType == nil {
                                loginFailReason.errorType = ""
                            }
                            guard let errorType = loginFailReason.errorType else { return }
                            if errorType == TwoFactorLoginErrorTypeEnum.invalidCode.rawValue {
                                completion(Return.fail(error: CustomErrors.invalidTwoFactorCode, response: .fail, value: nil), nil)
                            } else if errorType == TwoFactorLoginErrorTypeEnum.missingCode.rawValue {
                                completion(Return.fail(error: CustomErrors.missingTwoFactorCode, response: .fail, value: nil), nil)
                            } else {
                                completion(Return.fail(error: CustomErrors.unExpected("unExpected Error"), response: .fail, value: nil), nil)
                            }
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil), nil)
                        }
                    } else {
                        do {
                            let loginInfo = try decoder.decode(LoginResponseModel.self, from: data)
                            HandlerSettings.shared.user!.loggedInUser = loginInfo.loggedInUser
                            HandlerSettings.shared.isUserAuthenticated = (loginInfo.loggedInUser.username?.lowercased() == HandlerSettings.shared.user!.username.lowercased())
                            HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
                            
                            let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)
                            completion(Return.success(value: .success), sessionCache)
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil), nil)
                        }
                    }
                }
            }
        }
    }
    
    private func getTwoFactorLoginSmsRequestBody() -> [String: Any]{
        let content = [
            "two_factor_identifier" : HandlerSettings.shared.twoFactor!.twoFactorIdentifier,
            "username": HandlerSettings.shared.user!.username,
            "device_id": RequestMessageModel.generateDeviceIdFromGuid(guid: HandlerSettings.shared.device!.deviceGuid),
            "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            ]
        
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        return body
    }
    
    // resend twofactor sms
    func sendTwoFactorLoginSms(completion: @escaping (Result<Bool>) -> ()) throws {
        let body = getTwoFactorLoginSmsRequestBody()
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getSendTwoFactorLoginSmsUrl(), body: body, header: [:]) { (data, response, error) in
            if response?.statusCode == 200 {
                completion(Return.success(value: true))
            } else {
                completion(Return.fail(error: error, response: .fail, value: false))
            }
        }
    }
    
    func challengeLogin(completion: @escaping (Result<ResponseTypes>) -> ()) throws {
        let url = URL(string: HandlerSettings.shared.challenge!.url)!
        let content = [
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "device_id": HandlerSettings.shared.device!.deviceId
            //"choice": "1"
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: url, body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: .fail))
            } else {
                if response?.statusCode == 200 {
                    if let data = data {
                        if String(data: data, encoding: .utf8)!.contains("security code to verify your account") {
                            completion(Return.success(value: .verifyMethodRequired))
                        }
                    }
                } else {
                    completion(Return.fail(error: nil, response: .wrongRequest, value: .wrongRequest))
                }
            }
        }
    }
    
    func verifyMethod(of type: VerifyTypes, completion: @escaping (Result<VerifyResponse>) -> ()) throws {
        let url = URL(string: HandlerSettings.shared.challenge!.url)!
        let content = [
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "device_id": HandlerSettings.shared.device!.deviceId,
            "choice": type.rawValue
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: url, body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    if String(data: data, encoding: .utf8)!.contains("Enter Security Code") {
                        completion(Return.success(value: .codeSent))
                    } else {
                        completion(Return.fail(error: nil, response: .ok, value: .badChoice))
                    }
                }
            }
        }
    }
    
    func sendVerifyCode(securityCode: String, completion: @escaping (Result<LoginResultModel>, SessionCache?) -> ()) throws {
        let body: [String: Any] = [
            "security_code": securityCode,
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "guid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "device_id": HandlerSettings.shared.device!.deviceId
        ]

        let header = ["Host": "i.instagram.com"]
        let url = try URLs.getVerifyLoginUrl(challenge: HandlerSettings.shared.challenge!.apiPath)
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: url, body: body, header: header) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: .responseError), nil)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let loginInfo = try decoder.decode(LoginResponseModel.self, from: data)
                        if loginInfo.status! == "ok" {
                            HandlerSettings.shared.user!.loggedInUser = loginInfo.loggedInUser
                            HandlerSettings.shared.isUserAuthenticated = (loginInfo.loggedInUser.username?.lowercased() == HandlerSettings.shared.user!.username.lowercased())
                            HandlerSettings.shared.user!.rankToken = "\(HandlerSettings.shared.user!.loggedInUser.pk ?? 0)_\(HandlerSettings.shared.request!.phoneId )"
                            let sessionCache = SessionCache.init(user: HandlerSettings.shared.user!, device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: (HTTPCookieStorage.shared.cookies?.getInstagramCookies()?.toCookieData())!, isUserAuthenticated: true)

                            completion(Return.success(value: .success), sessionCache)
                        } else {
                            let error = CustomErrors.runTimeError("Please check the code we sent you and try again.")
                            completion(Return.fail(error: error, response: .fail, value: .badSecurityCode), nil)
                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: .exception), nil)
                    }
                }
            }
        }
    }
    
    // Its not working yet.
    func createAccount(account: CreateAccountModel, completion: @escaping (Bool) -> ()) throws {
        
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
    
    func logout(completion: @escaping (Result<Bool>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getLogoutUrl(), body: [:], header: [:], completion: { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .unknown, value: nil))
            } else {
                if let data  = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    do {
                        let logoutInfo = try decoder.decode(BaseStatusResponseModel.self, from: data)
                        if response?.statusCode != 200 {
                            completion(Return.fail(error: error, response: .fail, value: nil))
                        } else {
                            if logoutInfo.isOk() {
                                HandlerSettings.shared.isUserAuthenticated = false
                                completion(Return.success(value: true))
                            }
                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))                    }
                }
            }
        })
    }
    
    func searchUser(username: String, completion: @escaping (Result<[UserModel]>) -> ()) throws {
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
    
    func getUser(username: String, completion: @escaping (Result<UserModel>) -> ()) throws {
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
    
    func getUser(id: Int, completion: @escaping (Result<UserInfoModel>) -> ()) throws {
        
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
                     completionHandler: @escaping PaginationResponse<Result<[UserFeedModel]>>) throws {
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
            PaginationHandler.getPages(UserFeedModel.self,
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
                          completionHandler: @escaping PaginationResponse<Result<[UserShortModel]>>) throws {
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
            PaginationHandler.getPages(UserShortListModel.self,
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
                          completionHandler: @escaping PaginationResponse<Result<[UserShortModel]>>) throws {
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
            PaginationHandler.getPages(UserShortListModel.self,
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
    
    func getCurrentUser(completion: @escaping (Result<CurrentUserModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(format: "%ld", HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken
        ]
        
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getCurrentUser(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if response?.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let currentUser = try decoder.decode(CurrentUserModel.self, from: data)
                            completion(Return.success(value: currentUser))
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil))
                        }
                    } else {
                        let error = CustomErrors.runTimeError("The data couldn’t be read because it is missing error when decoding JSON.")
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                } else {
                    completion(Return.fail(error: error, response: .loginRequired, value: nil))
                }
            }
        }
    }

    func getRecentActivities(paginationParameters: PaginationParameters,
                             updateHandler: PaginationResponse<RecentActivitiesModel>?,
                             completionHandler: @escaping PaginationResponse<Result<[RecentActivitiesModel]>>) throws {
        PaginationHandler.getPages(RecentActivitiesModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getRecentActivities(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }

    func getRecentFollowingActivities(paginationParameters: PaginationParameters,
                                      updateHandler: PaginationResponse<RecentFollowingsActivitiesModel>?,
                                      completionHandler: @escaping PaginationResponse<Result<[RecentFollowingsActivitiesModel]>>) throws {
        PaginationHandler.getPages(RecentFollowingsActivitiesModel.self,
                                   for: paginationParameters,
                                   at: { try URLs.getRecentFollowingActivities(maxId: $0.nextMaxId ?? "") },
                                   updateHandler: updateHandler,
                                   completionHandler: completionHandler)
    }
    
    func removeFollower(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func approveFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func rejectFriendship(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func pendingFriendships(completion: @escaping (Result<PendingFriendshipsModel>) -> ()) throws {
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
    
    func followUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func unFollowUser(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func getFriendshipStatus(of userId: Int, completion: @escaping (Result<FriendshipStatusModel>) -> ()) throws {
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
    
    func getFriendshipStatuses(of userIds: [Int], completion: @escaping (Result<FriendshipStatusesModel>) -> ()) throws {
        
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
    
    func getBlockedList(completion: @escaping (Result<BlockedUsersModel>) -> ()) throws {
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
    
    func block(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func unBlock(userId: Int, completion: @escaping (Result<FollowResponseModel>) -> ()) throws {
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
    
    func recoverAccountBy(username: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws {
        try recoverAccountBy(email: username) { (result) in
            completion(result)
        }
    }
    
    func recoverAccountBy(email: String, completion: @escaping (Result<AccountRecovery>) -> ()) throws {
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
    
    func reportUser(userPk: Int, completion: @escaping (Result<Bool>) -> ()) throws {
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
    }
}
