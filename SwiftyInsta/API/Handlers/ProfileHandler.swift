//
//  ProfileHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

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
        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_csrftoken": storage.csrfToken]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Accounts.setPublic,
                         body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Set the account to private.
    public func markAsPrivate(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        let content = ["_uuid": handler!.settings.device.deviceGuid.uuidString,
                       "_csrftoken": storage.csrfToken]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Accounts.setPrivate,
                         body: .parameters(content)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Update password.
    public func update(password: String,
                       oldPassword: String,
                       completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let params: [String: Any] = ["id": true,
                                     "server_config_retrieval": 1,
                                     "_csrftoken": storage.csrfToken]
        requests.fetch(method: .post,
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
                guard case .success(let newEncPassword1) = Utilities.encryptPassword(from: headers, password) else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Cannot generate enc_password.")))
                    }
                }
                guard case .success(let newEncPassword2) = Utilities.encryptPassword(from: headers, password) else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Cannot generate enc_password.")))
                    }
                }
                guard case .success(let oldEncPassword) = Utilities.encryptPassword(from: headers, oldPassword) else {
                    return handler.settings.queues.response.async {
                        completionHandler(.failure(GenericError.custom("Cannot generate enc_password.")))
                    }
                }
                // prepare body.
                let content = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                               "_uid": storage.dsUserId,
                               "_csrftoken": storage.csrfToken,
                               "enc_old_password": oldEncPassword,
                               "enc_new_password1": newEncPassword1,
                               "enc_new_password2": newEncPassword2]
                me.requests.request(Status.self,
                                    method: .post,
                                    endpoint: Endpoint.Accounts.changePassword,
                                    body: .payload(content)) { completionHandler($0.map { $0.state == .ok }) }
            default:
                handler.settings.queues.response.async {
                    completionHandler(.failure(GenericError.custom("Invalid response.")))
                }
            }
        }
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
                         endpoint: Endpoint.Accounts.editProfile,
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
                                                         endpoint: Endpoint.Accounts.saveEditProfile,
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
                         endpoint: Endpoint.Accounts.editBiography,
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
                         endpoint: Endpoint.Accounts.removeProfilePicture,
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
                         endpoint: Endpoint.Accounts.changeProfilePicture,
                         body: .data(content),
                         headers: headers) { completionHandler($0.map { $0.state == .ok }) }
    }
}
