//
//  ProfileHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class ProfileHandler: Handler {
    /// Set the account to public.
    public func markAsPublic(completionHandler: @escaping (Result<ProfilePrivacyResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        var content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken]
        let encoder = JSONEncoder()

        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        
        requests.decodeAsync(ProfilePrivacyResponseModel.self,
                             method: .post,
                             url: try! URLs.setPublicProfile(),
                             body: .parameters(content),
                             completionHandler: completionHandler)
    }

    /// Set the account to private.
    public func markAsPrivate(completionHandler: @escaping (Result<ProfilePrivacyResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        var content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken]
        let encoder = JSONEncoder()

        let encodedContent = String(data: try! encoder.encode(content) , encoding: .utf8)!
        let hash = encodedContent.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureKey)
        let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        content.updateValue(signature, forKey: Headers.HeaderIGSignatureKey)
        content.updateValue(Headers.HeaderIGSignatureVersionValue, forKey: Headers.HeaderIGSignatureVersionKey)
        
        requests.decodeAsync(ProfilePrivacyResponseModel.self,
                             method: .post,
                             url: try! URLs.setPrivateProfile(),
                             body: .parameters(content),
                             completionHandler: completionHandler)
    }

    /// Update password.
    public func update(password: String,
                       oldPassword: String,
                       completionHandler: @escaping (Result<BaseStatusResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "old_password": oldPassword,
                       "new_password1": password,
                       "new_password2": password]
        requests.decodeAsync(BaseStatusResponseModel.self,
                             method: .post,
                             url: try! URLs.getChangePasswordUrl(),
                             body: .parameters(content),
                             completionHandler: completionHandler)
    }

    /// Edit profile.
    public func edit(username: String?,
                     name: String?,
                     biography: String?,
                     url: String?,
                     email: String?,
                     phone: String?,
                     gender: GenderTypes,
                     completionHandler: @escaping (Result<EditProfileModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        requests.decodeAsync(EditProfileModel.self,
                             method: .get,
                             url: try! URLs.getEditProfileUrl(),
                             deliverOnResponseQueue: false) { [weak self] in
                                guard let me = self, let handler = me.handler else {
                                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                                }
                                switch $0 {
                                case .failure(let error):
                                    handler.settings.queues.response.async {
                                        completionHandler(.failure(error))
                                    }
                                case .success(let decoded):
                                    guard decoded.status == "ok" else {
                                        return handler.settings.queues.response.async {
                                            completionHandler(.failure(CustomErrors.noError))
                                        }
                                    }
                                    let _name = (name ?? "").isEmpty ? decoded.user!.fullName!: (name ?? "")
                                    let _biography = (biography ?? "").isEmpty ? decoded.user!.biography!: (biography ?? "")
                                    let _url = (url ?? "").isEmpty ? decoded.user!.externalUrl!: (url ?? "")
                                    let _email = (email ?? "").isEmpty ? decoded.user!.email!: (email ?? "")
                                    let _phone = (phone ?? "").isEmpty ? decoded.user!.phoneNumber!: (phone ?? "")
                                    let _username = (username ?? "").isEmpty ? decoded.user!.username!: (username ?? "")
                                    
                                    let content = ["external_url": _url,
                                                   "gender": gender.rawValue,
                                                   "phone_number": _phone,
                                                   "_csrftoken": storage.csrfToken,
                                                   "username": _username,
                                                   "first_name": _name,
                                                   "_uid": storage.dsUserId,
                                                   "biography": _biography,
                                                   "_uuid": handler.settings.device.deviceGuid.uuidString,
                                                   "email": _email]
                                    let headers = ["Host": "i.instagram.com"]
                                    
                                    handler.requests.decodeAsync(EditProfileModel.self,
                                                                 method: .post,
                                                                 url: try! URLs.getSaveEditProfileUrl(),
                                                                 body: .parameters(content),
                                                                 headers: headers,
                                                                 completionHandler: completionHandler)
                                }
        }
    }

    /// Edit biography.
    public func edit(biography: String, completionHandler: @escaping (Result<BaseStatusResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let content = ["_csrftoken": storage.csrfToken,
                       "_uid": storage.dsUserId,
                       "_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "raw_text": biography]
        
        requests.decodeAsync(BaseStatusResponseModel.self,
                             method: .post,
                             url: try! URLs.getEditBiographyUrl(),
                             body: .parameters(content),
                             completionHandler: completionHandler)
    }

    /// Remove profile picture.
    public func deleteProfilePicture(completionHandler: @escaping (Result<EditProfileModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let content = ["_csrftoken": storage.csrfToken,
                       "_uid": storage.dsUserId,
                       "_uuid": handler!.settings.device.deviceGuid.uuidString]
        let headers = ["Host": "i.instagram.com"]
        
        requests.decodeAsync(EditProfileModel.self,
                             method: .post,
                             url: try! URLs.getRemoveProfilePictureUrl(),
                             body: .parameters(content),
                             headers: headers,
                             completionHandler: completionHandler)
    }

    /// Upload profile picture.
    public func upload(profilePicture photo: InstaPhoto, completionHandler: @escaping (Result<EditProfileModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)
        // prepare body.
        var content = Data()
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"upload_id\"\n\n")
        content.append(string: "\(uploadId)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_uuid\"\n\n")
        content.append(string: "\(handler!.settings.device.deviceGuid.uuidString)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"_csrftoken\"\n\n")
        content.append(string: "\(storage.csrfToken)\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Transfer-Encoding: binary\n")
        content.append(string: "Content-Type: application/octet-stream\n")
        content.append(string: "Content-Disposition: form-data; name=\"profile_pic\"; filename=r\(uploadId).jpg; filename*=utf-8''r\(uploadId).jpg\n\n")
        
        #if os(macOS)
            let imageData = photo.image.tiffRepresentation
        #else
            let imageData = photo.image.jpegData(compressionQuality: 1)
        #endif
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]
        
        requests.decodeAsync(EditProfileModel.self,
                             method: .post,
                             url: try! URLs.getChangePasswordUrl(),
                             body: .data(content),
                             headers: headers,
                             completionHandler: completionHandler)
    }
}
