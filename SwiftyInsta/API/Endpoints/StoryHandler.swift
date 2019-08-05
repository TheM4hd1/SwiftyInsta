//
//  StoryHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/26/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import CryptoSwift
import Foundation

public class StoryHandler: Handler {
    /// Get the story feed.
    public func tray(completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        requests.parse(Tray.self,
                       method: .get,
                       url: Result { try URLs.getStoryFeedUrl() },
                       completionHandler: completionHandler)
    }

    /// Get user's stories.
    public func by(user: User.Reference, completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        switch user {
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.by(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // load stories directly.
            requests.parse(Tray.self,
                           method: .get,
                           url: Result { try URLs.getUserStoryUrl(userId: pk) },
                           completionHandler: completionHandler)
        }
    }

    /// Get reel feed.
    public func reelBy(user: User.Reference, completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        switch user {
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user?.identity.primaryKey != nil:
                    handler.reelBy(user: .primaryKey(user!.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // load stories directly.
            requests.parse(Tray.self,
                           method: .get,
                           url: Result { try URLs.getUserStoryFeed(userId: pk) },
                           processingHandler: { Tray(rawResponse: $0.reel) },
                           completionHandler: completionHandler)
        }
    }

    /// Upload photo.
    public func upload(photo: InstaPhoto, completionHandler: @escaping (Result<UploadPhotoResponse, Error>) -> Void) {
        #warning("uses old models.")
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let uploadId = String(Date().millisecondsSince1970 / 1000)
        // prepare content.
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
        content.append(string: "Content-Type: text/plain; charset=utf-8\n")
        content.append(string: "Content-Disposition: form-data; name=\"image_compression\"\n\n")
        content.append(string: "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\n")
        content.append(string: "--\(uploadId)\n")
        content.append(string: "Content-Transfer-Encoding: binary\n")
        content.append(string: "Content-Type: application/octet-stream\n")
        content.append(string: ["Content-Disposition: form-data; name=photo;",
                                "filename=pending_media_\(uploadId).jpg;",
                                "filename*=utf-8''pending_media_\(uploadId).jpg\n\n"].joined(separator: " "))

        #if os(macOS)
        let imageData = photo.image.tiffRepresentation
        #else
        let imageData = photo.image.jpegData(compressionQuality: 1)
        #endif
        content.append(imageData!)
        content.append(string: "\n--\(uploadId)--\n\n")
        let headers = ["Content-Type": "multipart/form-data; boundary=\"\(uploadId)\""]

        requests.decode(UploadPhotoResponse.self,
                        method: .post,
                        url: Result { try URLs.getUploadPhotoUrl() },
                        body: .data(content),
                        headers: headers,
                        deliverOnResponseQueue: false) { [weak self] in
                            guard let me = self, let handler = me.handler else {
                                return completionHandler(.failure(GenericError.weakObjectReleased))
                            }
                            switch $0 {
                            case .failure(let error):
                                handler.settings.queues.response.async {
                                    completionHandler(.failure(error))
                                }
                            case .success(let decoded):
                                guard decoded.status == "ok" else {
                                    return handler.settings.queues.response.async {
                                        completionHandler(.failure(GenericError.unknown))
                                    }
                                }
                                me.configure(photo: photo,
                                             with: uploadId,
                                             caption: photo.caption,
                                             completionHandler: completionHandler)
                            }
        }
    }

    // Set up photo.
    func configure(photo: InstaPhoto,
                   with uploadId: String,
                   caption: String,
                   completionHandler: @escaping (Result<UploadPhotoResponse, Error>) -> Void) {
        #warning("uses old models.")
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        // prepare body.
        let data = ConfigureStoryUploadModel.init(uuid: handler!.settings.device.deviceGuid.uuidString,
                                                  uid: storage.dsUserId,
                                                  csrfToken: storage.csrfToken,
                                                  sourceType: "1",
                                                  caption: caption,
                                                  uploadId: uploadId,
                                                  disableComments: false,
                                                  configureMode: 1,
                                                  cameraPosition: "unknown")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(data), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes)

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.decode(UploadPhotoResponse.self,
                            method: .post,
                            url: Result { try URLs.getConfigureStoryUrl() },
                            body: .parameters(body),
                            completionHandler: completionHandler)
        } catch { completionHandler(.failure(error)) }
    }

    /// Get story viewers.
    public func viewers(forStory storyId: String,
                        with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<User, StoryViewers>?,
                        completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.parse(User.self,
                    paginatedResponse: StoryViewers.self,
                    with: paginationParameters,
                    at: { try URLs.getStoryViewersUrl(pk: storyId, maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.users.array?.map(User.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Mark stories as seen.
    public func mark(stories: [Media],
                     with sourceId: String?,
                     asSeen seen: Bool,
                     completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        guard seen else {
            return handler!.settings.queues.response.async {
                completionHandler(.failure(GenericError.custom("You cannot \"unsee\" stories.")))
            }
        }

        var reels: [String: [String]] = [:]
        let maxSeenAt = Int(Date().timeIntervalSince1970)
        var seenAt = Int(maxSeenAt) - (3 * stories.count)

        for item in stories {
            let takenAt = Int(item.takenAt.timeIntervalSince1970)
            if seenAt < takenAt {
                seenAt = takenAt + 2
            }
            if seenAt > maxSeenAt {
                seenAt = maxSeenAt
            }
            let itemSourceId = (sourceId == nil) ? String(item.user!.identity.primaryKey!): sourceId!
            let reelId = item.identity.identifier! + "_" + itemSourceId
            reels[reelId] = [String(takenAt) + "_" + String(seenAt)]
            seenAt += Int.random(in: 1...3)
        }
        let data  = SeenStory(uuid: handler!.settings.device.deviceGuid.uuidString,
                              uid: storage.dsUserId,
                              csrfToken: storage.csrfToken,
                              containerModule: "feed_timeline",
                              reels: reels,
                              reelMediaSkipped: [:],
                              liveVods: [:],
                              liveVodsSkipped: [:],
                              nuxes: [:],
                              nuxesSkipped: [:])

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(data), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes)

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.decode(Status.self,
                            method: .post,
                            url: Result { try URLs.markStoriesAsSeenUrl() },
                            body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        } catch { completionHandler(.failure(error)) }
    }

    /// Get reels media feed.
    public func reelsMedia(_ feeds: [String], completionHandler: @escaping (Result<[String: Tray], Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        let data = RequestReelsMediaFeed(supportedCapabilitiesNew: SupportedCapability.generate(),
                                         uuid: handler!.settings.device.deviceGuid.uuidString,
                                         uid: storage.dsUserId,
                                         csrfToken: storage.csrfToken,
                                         userIds: feeds,
                                         source: "feed_timeline")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payload = try? String(data: encoder.encode(data), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Headers.igSignatureKey, variant: .sha256).authenticate(payload.bytes)

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
            ]

            requests.parse([String: Tray].self,
                           method: .post,
                           url: Result { try URLs.getReelsMediaFeed() },
                           body: .parameters(body),
                           processingHandler: { $0.reels.dictionary?.mapValues { Tray(rawResponse: $0) } ?? [:] },
                           completionHandler: completionHandler)
        } catch { completionHandler(.failure(error)) }
    }

    /// Get reels archive.
    func archive(with paginationParameters: PaginationParameters,
                 updateHandler: PaginationUpdateHandler<TrayArchive, AnyPaginatedResponse>?,
                 completionHandler: @escaping PaginationCompletionHandler<TrayArchive>) {
        pages.parse(TrayArchive.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try URLs.getStoryArchiveUrl(maxId: $0.nextMaxId ?? "") },
                    processingHandler: { $0.rawResponse.items.array?.map(TrayArchive.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }
}
