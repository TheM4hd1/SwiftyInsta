//
//  AuthenticationHandler.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 23/07/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import CryptoSwift
import Foundation

// swiftlint:disable all
final class AuthenticationHandler: Handler {
    // MARK: Log in
    func authenticate(cache: Authentication.Response, completionHandler: @escaping (Result<Authentication.Response, Error>) -> Void) {
        var cache = cache
        // update handler.
        handler.settings.device = cache.device
        handler.response = cache
        // fetch the user.
        handler.users.current(delay: 0...0) { [weak self] in
            switch $0 {
            case .success(let user):
                // update user info alone.
                self?.handler.response?.storage?.user = user
                cache.storage?.user = user
                completionHandler(.success(cache))
            case .failure(let error): completionHandler(.failure(error))
            }
        }
    }
    
    func authenticate(user: Credentials,
                      completionHandler: @escaping (Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        // update user.
        let user = user
        user.handler = handler
        // remove cookies.
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        // ask for login.
        requests.fetch(method: .get, url: Result { try Endpoint.Authentication.home.url() }) { [weak self] in
            guard let me = self, let handler = me.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            // analyze response.
            switch $0 {
            case .failure(let error): handler.settings.queues.response.async { completionHandler(.failure(error)) }
            case .success((_, let response?)):
                // obtain cookies.
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: response.allHeaderFields as? [String: String] ?? [:],
                                                 for: response.url!)
                guard let csrfToken = cookies.first(where: { $0.name == "csrftoken" })?.value else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Invalid cookies.")))
                    }
                }
                user.csrfToken = csrfToken
                let params: [String: Any] = ["id": true,
                                             "server_config_retrieval": 1,
                                             "_csrftoken": csrfToken]
                me.requests.fetch(method: .post,
                                  url: Result { try Endpoint.Accounts.launcherSync.url() },
                                  body: .parameters(params),
                                  headers: [:],
                                  delay: nil) { [weak self] in
                    guard let me = self, let handler = me.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
                    switch $0 {
                    case .failure(let error): handler.settings.queues.response.async { completionHandler(.failure(error)) }
                    case .success((_, let response?)):
                        guard let headers = response.allHeaderFields as? [String: String] else {
                            return handler.settings.queues.response.async {
                                completionHandler(.failure(GenericError.custom("Cannot fetch headers.")))
                            }
                        }
                        guard case .success(let encPassword) = Utilities.encryptPassword(from: headers, user.password) else {
                            return handler.settings.queues.response.async {
                                completionHandler(.failure(GenericError.custom("Cannot generate enc_password.")))
                            }
                        }
                        // prepare body.
                        let body = ["username": user.username,
                                    "reg_login": "0",
                                    "enc_password": encPassword,
                                    "device_id": me.handler.settings.device.deviceGuid.uuidString,
                                    "login_attempt_count": "1",
                                    "phone_id": me.handler.settings.device.phoneGuid.uuidString]
                        
                        me.requests.request(CredentialsAuthenticationResponse.self,
                                            method: .post,
                                            endpoint: Endpoint.Accounts.login,
                                            body: .payload(body),
                                            headers: [:],
                                            options: [],
                                            delay: 0...0) {
                            switch $0 {
                            case .failure(let error):
                                handler.settings.queues.response.async {
                                    completionHandler(.failure(error))
                                }
                            case .success(let response):
                                // check for status.
                                if let challenge = response.challenge {
                                    user.completionHandler = completionHandler
                                    user.response = .challenge(challenge)
                                    me.challengeInfo(for: user) { form in
                                        guard let form = form else { return }
                                        user.response = .challengeForm(form)
                                        handler.settings.queues.response.async {
                                            completionHandler(.failure(AuthenticationError.checkpoint(suggestions: form.suggestion)))
                                            // ask for verification code.
                                            me.challenge(csrfToken: csrfToken, challenge: form, verification: user.verification) {
                                                completionHandler(.failure($0))
                                            }
                                        }
                                    }
                                } else if let identifier = response.twoFactorInfo?.identifier {
                                    user.completionHandler = completionHandler
                                    user.response = .twoFactor(identifier)
                                    handler.settings.queues.response.async {
                                        completionHandler(.failure(AuthenticationError.twoFactor))
                                    }
                                } else if let authentication = response.user {
                                    // check for authentication status.
                                    if let dsUserId = authentication.identity.primaryKey {
                                        user.response = .success
                                        // create session cache.
                                        let cookies = HTTPCookieStorage.shared
                                            .cookies?.filter { $0.domain.contains(".instagram.com") } ?? []
                                        let storage = Authentication.Storage(
                                            dsUserId: "\(dsUserId)",
                                            csrfToken: csrfToken,
                                            sessionId: cookies.first(where: { $0.name == "sessionid" })!.value,
                                            rankToken: "\(dsUserId)"+"_"+handler.settings.device.phoneGuid.uuidString,
                                            user: nil
                                        )
                                        let cache = Authentication.Response(device: handler.settings.device,
                                                                            storage: storage,
                                                                            data: cookies.data)
                                        // actually authenticate.
                                        handler.authenticate(with: .cache(cache), completionHandler: completionHandler)
                                    } else {
                                        user.response = .failure
                                        handler.settings.queues.response.async {
                                            completionHandler(.failure(GenericError.custom("Unknown error.")))
                                        }
                                    }
                                } else if response.invalidCredentials ?? false {
                                    if let errorType = response.errorType {
                                        if errorType.elementsEqual("invalid_user") {
                                            user.response = .failure
                                            handler.settings.queues.response.async {
                                                completionHandler(.failure(AuthenticationError.invalidUsername))
                                            }
                                        } else {
                                            user.response = .failure
                                            handler.settings.queues.response.async {
                                                completionHandler(.failure(AuthenticationError.invalidPassword))
                                            }
                                        }
                                    }
                                } else {
                                    user.response = .failure
                                    handler.settings.queues.response.async {
                                        completionHandler(.failure(GenericError.custom("Unknown error.")))
                                    }
                                }
                            }
                        }
                    default:
                        handler.settings.queues.response.async {
                            completionHandler(.failure(GenericError.custom("Invalid response.")))
                        }
                    }
                }
            default:
                user.response = .failure
                handler.settings.queues.response.async {
                    completionHandler(.failure(GenericError.custom("Invalid response.")))
                }
            }
        }
    }

    func challenge(csrfToken: String,
                   challenge: ChallengeForm,
                   verification: Credentials.Verification,
                   completionHandler: @escaping (Error) -> Void) {
        // prepare body.
        let body = ["choice": verification.rawValue,
                    "bloks_versioning_id": Constants.bloksVersioningId,
                    "_uuid": handler.settings.device.deviceGuid.uuidString,
                    "challenge_context": challenge.context ?? "",
                    "minification_cache_key": "default1",
                    "_csrftoken": csrfToken]
        guard let bloksAction = challenge.bloksAction else { return }
        requests.fetch(method: .post,
                       url: Result { try Endpoint.Accounts.challengeBloksAction.bloksAction(bloksAction)!.url() },
                       body: .payload(body),
                       headers: [:],
                       delay: 0...0) { [weak self] in
            guard let me = self, let handler = me.handler else { return completionHandler(GenericError.weakObjectReleased) }
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(error)
                }
            case .success((_, let response)):
                if response?.statusCode == 200 {// notify errors.
                    handler.settings.queues.response.async {
                        if verification == .email && challenge.suggestion?.contains("@") ?? false {
                            guard let email = challenge.suggestion?.first(where: { $0.contains("@")} ) else { return }
                            completionHandler(GenericError.custom("Enter the 6-digit code we sent to the email:\n\(email)"))
                        } else {
                            guard let phoneNumber = challenge.suggestion?.first(where: { $0.contains("+")} ) else { return }
                            completionHandler(GenericError.custom("Enter the 6-digit code we sent to your number:\n\(phoneNumber)"))
                        }
                    }
                } else {
                    handler.settings.queues.response.async {
                        completionHandler(GenericError.custom("Invalid response."))
                    }
                }
            }
        }
    }

    func challengeInfo(for user: Credentials, completionHandler: @escaping (ChallengeForm?) -> Void) {
        guard case .challenge(let info) = user.response else { return completionHandler(nil) }
        guard let apiPath = info.apiPath else { return }
        guard let context = info.context else { return }
        let deviceId = handler.settings.device.deviceGuid.uuidString
        requests.request(ChallengeForm.self,
                         method: .get,
                         endpoint: Endpoint.Accounts.challenge.apiPath(apiPath.trimmingCharacters(in: .init(charactersIn: "/"))).deviceId(deviceId).challenge(context)) { result in
            switch result {
            case .failure(_):
                completionHandler(nil)
            case .success(let form):
                completionHandler(form)
            }
        }
    }

    func code(for credentials: Credentials) {
        guard let code = credentials.code,
              credentials.csrfToken != nil,
              let completionHandler = credentials.completionHandler else {
            return print("Invalid setup.")
        }
        // check for response.
        switch credentials.response {
        case .success, .failure, .unknown:
            handler.settings.queues.response.async {
                completionHandler(.failure(GenericError.custom("No code required.")))
            }
        case .challenge(_):
            send(challengeCode: code.1, for: credentials, completionHandler: completionHandler)
        case .twoFactor(let identifier):
            send(twoFactorCode: code, with: identifier, for: credentials, completionHandler: completionHandler)
        case .challengeForm(_):
            send(challengeCode: code.1, for: credentials, completionHandler: completionHandler)
        }
    }

    func send(challengeCode code: String,
              for user: Credentials,
              completionHandler: @escaping (Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        let user = user
        guard case .challengeForm(let form) = user.response else { return }
        guard let bloksAction = form.bloksAction else { return }
        guard let context = form.context else { return }
        guard let csrftoken = user.csrfToken else { return }
        // prepare body
        let body = ["bloks_versioning_id": Constants.bloksVersioningId,
                    "_uuid": handler.settings.device.deviceGuid.uuidString,
                    "security_code": code,
                    "challenge_context": context,
                    "minification_cache_key": "default1",
                    "_csrftoken": csrftoken]

        requests.fetch(method: .post,
                       url: Result { try Endpoint.Accounts.challengeBloksAction.bloksAction(bloksAction)!.url() },
                       body: .payload(body),
                       headers: [:],
                       delay: 0...0) { [weak self] in
            guard let me = self, let handler = me.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            // check for response.
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success((let data, _)) where data != nil:
                let data = data!
                let string = String(data: data, encoding: .utf8)!
                if string.contains("ig.action.navigation.ClearChallenge") {
                    // create session cache.
                    let cookies = HTTPCookieStorage.shared.cookies?.filter { $0.domain.contains(".instagram.com") } ?? []
                    if cookies.contains(where: { $0.name == "ds_user_id" }) {
                        user.response = .success
                        let dsUserId = cookies.first(where: { $0.name == "ds_user_id" })!.value
                        let storage = Authentication.Storage(dsUserId: dsUserId,
                                                             csrfToken: user.csrfToken ?? cookies.first(where: { $0.name == "csrftoken" })!.value,
                                                             sessionId: cookies.first(where: { $0.name == "sessionid" })!.value,
                                                             rankToken: dsUserId+"_"+handler.settings.device.phoneGuid.uuidString,
                                                             user: nil)
                        let cache = Authentication.Response(device: handler.settings.device,
                                                            storage: storage,
                                                            data: cookies.data)
                        handler.authenticate(with: .cache(cache), completionHandler: completionHandler)
                    } else {
                        handler.settings.queues.response.async {
                            completionHandler(.failure(AuthenticationError.checkpointLoop))
                        }
                    }
                } else {
                    handler.settings.queues.response.async {
                        completionHandler(.failure(AuthenticationError.invalidCode))
                    }
                }
            default:
                handler.settings.queues.response.async {
                    completionHandler(.failure(GenericError.custom("Invalid response.")))
                }
            }
        }
    }

    /// resend two factor sms code
    func resend(user: Credentials, identifier: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        let user = user
        let body = ["waterfall_id": UUID().uuidString,
                    "device_id": handler.settings.device.deviceGuid.uuidString,
                    "username": user.username,
                    "two_factor_identifier": identifier]
        requests.fetch(method: .post,
                       url: Result { try Endpoint.Accounts.sendTwoFactorLoginSms.url() },
                       body: .payload(body),
                       headers: [:],
                       delay: nil) { [weak self] in
            guard let me = self else { return }
            switch $0 {
            case .failure(let error): me.handler.settings.queues.response.async { completionHandler(.failure(error)) }
            case .success((let data, let response)):
                if response?.statusCode == 200 {
                    guard let data = data else { return }
                    do {
                        guard let identifier = try DynamicResponse(data: data).twoFactorInfo.twoFactorIdentifier.string else { return }
                        user.response = .twoFactor(identifier)
                        me.handler.settings.queues.response.async { completionHandler(.success(true)) }
                    } catch { me.handler.settings.queues.response.async { completionHandler(.failure(error)) } }
                } else {
                    me.handler.settings.queues.response.async { completionHandler(.failure(GenericError.custom("rate_limit_error"))) }
                }
            }
        }
    }

    func send(twoFactorCode code: (Credentials.VerificationCodeType, String),
              with identifier: String,
              for user: Credentials,
              completionHandler: @escaping (Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        let user = user
        let body = ["waterfall_id": UUID().uuidString,
                    "trust_this_device": "1",
                    "device_id": handler.settings.device.deviceGuid.uuidString,
                    "verification_code": code.1,
                    "username": user.username,
                    "verification_method": code.0.rawValue,
                    "phone_id": handler.settings.device.phoneGuid.uuidString,
                    "two_factor_identifier": identifier]

        requests.fetch(method: .post,
                       url: Result { try Endpoint.Accounts.twoFactorLogin.url() },
                       body: .payload(body),
                       headers: [:],
                       delay: 0...0) { [weak self] in
            guard let me = self, let handler = me.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            // check for response.
            switch $0 {
            case .failure(let error):
                handler.settings.queues.response.async {
                    completionHandler(.failure(error))
                }
            case .success((_, let response)) where response != nil:
                let response = response!
                switch response.statusCode {
                case 200:
                    // log in.
                    user.response = .success
                    // create session cache.
                    let cookies = HTTPCookieStorage.shared.cookies?.filter { $0.domain.contains(".instagram.com") } ?? []
                    let dsUserId = cookies.first(where: { $0.name == "ds_user_id" })!.value
                    let storage = Authentication.Storage(
                        dsUserId: dsUserId,
                        csrfToken: user.csrfToken ?? cookies.first(where: { $0.name == "csrftoken" })!.value,
                        sessionId: cookies.first(where: { $0.name == "sessionid" })!.value,
                        rankToken: dsUserId+"_"+handler.settings.device.phoneGuid.uuidString,
                        user: nil
                    )
                    let cache = Authentication.Response(device: handler.settings.device,
                                                        storage: storage,
                                                        data: cookies.data)
                    handler.authenticate(with: .cache(cache), completionHandler: completionHandler)
                case 400:
                    user.response = .failure
                    handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Please check the security code and try again.")))
                    }
                default:
                    user.response = .failure
                    handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Invalid response.")))
                    }
                }
            default:
                user.response = .failure
                handler.settings.queues.response.async {
                    completionHandler(.failure(GenericError.custom("Invalid response.")))
                }
            }
        }
    }

    // MARK: Log out
    func invalidate(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard handler.user != nil else {
            return handler.settings.queues.response.async {
                completionHandler(.failure(GenericError.custom("User is not logged in.")))
            }
        }
        handler.requests.fetch(method: .post, url: Result { try Endpoint.Accounts.logout.url() }) { [weak self] in
            guard let handler = self?.handler else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
            let result = $0.flatMap { data, response -> Result<Bool, Error> in
                do {
                    guard let data = data, response?.statusCode == 200 else { throw GenericError.custom("Invalid response.") }
                    // decode data.
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decoded = try decoder.decode(Status.self, from: data)
                    return .success(decoded.state == .ok)
                } catch { return .failure(error) }
            }
            handler.settings.queues.response.async { completionHandler(result) }
        }
    }
}
