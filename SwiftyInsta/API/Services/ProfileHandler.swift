//
//  ProfileHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol ProfileHandlerProtocol {
    func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws
    func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws
    func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws
}

class ProfileHandler: ProfileHandlerProtocol {
    static let shared = ProfileHandler()
    
    private init() {
        
    }
    
    func setAccountPublic(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        let encoder = JSONEncoder()
        var content = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken
        ]
        
        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.setPublicProfile(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(ProfilePrivacyResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))                    }
                }
            }
        }
    }
    
    func setAccountPrivate(completion: @escaping (Result<ProfilePrivacyResponseModel>) -> ()) throws {
        let encoder = JSONEncoder()
        var content = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken
        ]
        
        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.setPrivateProfile(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(ProfilePrivacyResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func setNewPassword(oldPassword: String, newPassword: String, completion: @escaping (Result<BaseStatusResponseModel>) -> ()) throws {
        let body = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "old_password": oldPassword,
            "new_password1": newPassword,
            "new_password2": newPassword
        ]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getChangePasswordUrl(), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(BaseStatusResponseModel.self, from: data)
                        if value.isOk() {
                            completion(Return.success(value: value))
                        } else {
                            let message = value.message!.errors!.joined(separator: "\n")
                            let error = CustomErrors.groupedError(message)
                            completion(Return.fail(error: error, response: .fail, value: value))
                        }
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }

}
