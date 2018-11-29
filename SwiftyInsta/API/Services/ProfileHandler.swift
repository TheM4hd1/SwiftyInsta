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
    func editProfile(name: String, biography: String, url: String, email: String, phone: String, gender: GenderTypes, newUsername: String, completion: @escaping (Result<EditProfileModel>) -> ()) throws
    func editBiography(text bio: String, completion: @escaping (Result<Bool>) -> ()) throws
    func removeProfilePicture(completion: @escaping (Result<EditProfileModel>) -> ()) throws
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

    func editProfile(name: String, biography: String, url: String, email: String, phone: String, gender: GenderTypes, newUsername: String = "", completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: try URLs.getEditProfileUrl(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if response?.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let user = try decoder.decode(EditProfileModel.self, from: data)
                            if user.status! == "ok" {
                                let _name = name.isEmpty ? user.user!.fullName!: name
                                let _biography = biography.isEmpty ? user.user!.biography!: biography
                                let _url = url.isEmpty ? user.user!.externalUrl!: url
                                let _email = email.isEmpty ? user.user!.email!: email
                                let _phone = phone.isEmpty ? user.user!.phoneNumber!: phone
                                let _username = newUsername.isEmpty ? user.user!.username!: newUsername
                                
                                let content = [
                                    "external_url": _url,
                                    "gender": gender.rawValue,
                                    "phone_number": _phone,
                                    "_csrftoken": HandlerSettings.shared.user!.csrfToken,
                                    "username": _username,
                                    "first_name": _name,
                                    "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
                                    "biography": _biography,
                                    "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
                                    "email": _email
                                ]
                                
                                let header = ["Host": "i.instagram.com"]
                                HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try! URLs.getSaveEditProfileUrl(), body: content, header: header, completion: { (data, response, error) in
                                    if let error = error {
                                        completion(Return.fail(error: error, response: .fail, value: nil))
                                    } else {
                                        if let data = data {
                                            if response?.statusCode == 200 {
                                                let value = try? decoder.decode(EditProfileModel.self, from: data)
                                                completion(Return.success(value: value))
                                            } else {
                                                completion(Return.fail(error: nil, response: .unknown, value: nil))
                                            }
                                        }
                                    }
                                })
                            } else {
                                completion(Return.fail(error: nil, response: .unknown, value: nil))
                            }
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil))
                        }
                    }
                }
            }
        }
    }
    
    func editBiography(text bio: String, completion: @escaping (Result<Bool>) -> ()) throws {
        let content = [
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "raw_text": bio
        ]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getEditBiographyUrl(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: false))
            } else {
                if response?.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let status = try decoder.decode(BaseStatusResponseModel.self, from: data)
                            if status.isOk() {
                                completion(Return.success(value: true))
                            } else {
                                completion(Return.fail(error: error, response: .ok, value: false))
                            }
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: false))
                        }
                    }
                } else {
                    completion(Return.fail(error: nil, response: .unknown, value: false))
                }
            }
        }
    }
    
    func removeProfilePicture(completion: @escaping (Result<EditProfileModel>) -> ()) throws {
        let content = [
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString
        ]
        
        let header = ["Host": "i.instagram.com"]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getRemoveProfilePictureUrl(), body: content, header: header) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if response?.statusCode == 200 {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let value = try decoder.decode(EditProfileModel.self, from: data)
                            completion(Return.success(value: value))
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil))
                        }
                    }
                } else {
                    completion(Return.fail(error: nil, response: .unknown, value: nil))
                }
            }
        }
    }
}
