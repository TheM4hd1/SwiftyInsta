//
//  ProfileHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import CryptoSwift
import Foundation

/// **Instagram** accepted `Gender`s.
public enum Gender: String {
    /// Male.
    case male = "1"
    /// Female.
    case female = "2"
    /// Unknown.
    case unknown = "3"
}

public final class ProfileHandler: Handler {
    /// Set the account to public.
    public func markAsPublic(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        var content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken]
        let encoder = JSONEncoder()
        guard let encodedContent = try? String(data: encoder.encode(content), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(encodedContent.bytes).toHexString()
            let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
            content.updateValue(signature, forKey: Headers.igSignatureKey)
            content.updateValue(Headers.igSignatureVersionValue, forKey: Headers.igSignatureVersionKey)

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoints.Accounts.setPublic,
                             body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
        } catch { completionHandler(.failure(error)) }
    }

    /// Set the account to private.
    public func markAsPrivate(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        var content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken]
        let encoder = JSONEncoder()
        guard let encodedContent = try? String(data: encoder.encode(content), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(encodedContent.bytes).toHexString()
            let signature = "\(hash).\(encodedContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
            content.updateValue(signature, forKey: Headers.igSignatureKey)
            content.updateValue(Headers.igSignatureVersionValue, forKey: Headers.igSignatureVersionKey)

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoints.Accounts.setPrivate,
                             body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
        } catch { completionHandler(.failure(error)) }
    }

    /// Update password.
    public func update(password: String,
                       oldPassword: String,
                       completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "old_password": oldPassword,
                       "new_password1": password,
                       "new_password2": password]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoints.Accounts.changePassword,
                         body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Edit profile.
    public func edit(username: String?,
                     name: String?,
                     biography: String?,
                     url: String?,
                     email: String?,
                     phone: String?,
                     gender: Gender,
                     completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        requests.request(User.self,
                         method: .get,
                         endpoint: Endpoints.Accounts.editProfile,
                         options: .validateResponse) { [weak self] in
                            guard let me = self, let handler = me.handler else {
                                return completionHandler(.failure(GenericError.weakObjectReleased))
                            }
                            switch $0 {
                            case .failure(let error):
                                handler.settings.queues.response.async {
                                    completionHandler(.failure(error))
                                }
                            case .success(let decoded):
                                guard decoded.rawResponse.status.string == "ok" else {
                                    return handler.settings.queues.response.async {
                                        completionHandler(.failure(GenericError.unknown))
                                    }
                                }
                                guard decoded.identity.primaryKey != nil && !decoded.username.isEmpty else {
                                    return handler.settings.queues.response.async {
                                        completionHandler(.failure(GenericError.custom("Invalid response.")))
                                    }
                                }
                                let user = decoded
                                let name = name ?? user.rawResponse.fullName.string ?? ""
                                let biography = biography ?? user.biography ?? ""
                                let email = email ?? user.email ?? ""
                                let phone = phone ?? user.phoneNumber ?? ""
                                let username = username ?? user.username
                                let url = url ?? user.website?.absoluteString ?? ""

                                let content = ["external_url": url,
                                               "gender": gender.rawValue,
                                               "phone_number": phone,
                                               "_csrftoken": storage.csrfToken,
                                               "username": username,
                                               "first_name": name,
                                               "_uid": storage.dsUserId,
                                               "biography": biography,
                                               "_uuid": handler.settings.device.deviceGuid.uuidString,
                                               "email": email]
                                let headers = ["Host": "i.instagram.com"]

                                handler.requests.request(Status.self,
                                                         method: .post,
                                                         endpoint: Endpoints.Accounts.saveEditProfile,
                                                         body: .parameters(content),
                                                         headers: headers) { completionHandler($0.map { $0.state == .ok }) }
                            }
        }
    }

    /// Edit biography.
    public func edit(biography: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let content = ["_csrftoken": storage.csrfToken,
                       "_uid": storage.dsUserId,
                       "_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "raw_text": biography]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoints.Accounts.editBiography,
                         body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Remove profile picture.
    public func deleteProfilePicture(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let content = ["_csrftoken": storage.csrfToken,
                       "_uid": storage.dsUserId,
                       "_uuid": handler!.settings.device.deviceGuid.uuidString]
        let headers = ["Host": "i.instagram.com"]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoints.Accounts.removeProfilePicture,
                         body: .parameters(content),
                         headers: headers) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Upload profile picture.
    public func upload(profilePicture photo: Upload.Picture, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
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
        content.append(string: ["Content-Disposition: form-data;",
                                "name=\"profile_pic\";",
                                "filename=r\(uploadId).jpg;",
                                "filename*=utf-8''r\(uploadId).jpg\n\n"].joined(separator: " "))

        #if os(macOS)
        let imageData = photo.image.tiffRepresentation
        #else
        let imageData = photo.image.jpegData(compressionQuality: 1)
        #endif
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoints.Accounts.changeProfilePicture,
                         body: .data(content),
                         headers: headers) { completionHandler($0.map { $0.state == .ok }) }
    }
}
