//
//  StoryHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/26/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public class StoryHandler: Handler {
    /// Get the story feed.
    public func tray(completionHandler: @escaping (Result<StoryFeedModel, Error>) -> Void) {
        requests.decodeAsync(StoryFeedModel.self,
                             method: .get,
                             url: URLs.getStoryFeedUrl(),
                             completionHandler: completionHandler)
    }

    /// Get user's stories.
    public func by(user: UserReference, completionHandler: @escaping (Result<TrayModel, Error>) -> Void) {
        switch user {
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.by(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // load stories directly.
            requests.decodeAsync(TrayModel.self,
                                 method: .get,
                                 url: URLs.getUserStoryUrl(userId: pk),
                                 completionHandler: completionHandler)
        }
    }

    /// Get reel feed.
    public func reelBy(user: UserReference, completionHandler: @escaping (Result<StoryReelFeedModel, Error>) -> Void) {
        switch user {
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased))
                }
                switch $0 {
                case .success(let user) where user?.pk != nil:
                    handler.reelBy(user: .pk(user!.pk!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(CustomErrors.runTimeError("No user matching `username`.")))
                }
            }
        case .pk(let pk):
            // load stories directly.
            requests.decodeAsync(StoryReelFeedModel.self,
                                 method: .get,
                                 url: URLs.getUserStoryFeed(userId: pk),
                                 completionHandler: completionHandler)
        }
    }

    /// Upload photo.
    public func upload(photo: InstaPhoto, completionHandler: @escaping (Result<UploadPhotoResponse, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
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

        requests.decodeAsync(UploadPhotoResponse.self,
                             method: .post,
                             url: URLs.getUploadPhotoUrl(),
                             body: .data(content),
                             headers: headers,
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
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
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
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid request.")))
        }
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.igSignatureValue)

        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
        ]

        requests.decodeAsync(UploadPhotoResponse.self,
                             method: .post,
                             url: URLs.getConfigureStoryUrl(),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }

    /// Get story viewers.
    public func viewers(forStory storyId: String,
                        with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<StoryViewers>?,
                        completionHandler: @escaping PaginationCompletionHandler<StoryViewers>) {
        pages.fetch(StoryViewers.self,
                    with: paginationParameters,
                    at: { URLs.getStoryViewersUrl(pk: storyId, maxId: $0.nextMaxId ?? "") },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Mark stories as seen.
    public func mark(stories: [TrayItems],
                     with sourceId: String?,
                     asSeen seen: Bool,
                     completionHandler: @escaping (Result<BaseStatusResponseModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
        }
        guard seen else {
            return handler!.settings.queues.response.async {
                completionHandler(.failure(CustomErrors.runTimeError("You cannot \"unsee\" stories.")))
            }
        }

        var reels: [String: [String]] = [:]
        let maxSeenAt = Int(Date().timeIntervalSince1970)
        var seenAt = Int(maxSeenAt) - (3 * stories.count)

        for item in stories {
            let takenAt = item.takenAt!
            if seenAt < takenAt {
                seenAt = takenAt + 2
            }
            if seenAt > maxSeenAt {
                seenAt = maxSeenAt
            }
            let itemSourceId = (sourceId == nil) ? String(item.user!.pk!): sourceId!
            let reelId = String(item.id!) + "_" + itemSourceId
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
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid request.")))
        }
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.igSignatureValue)

        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
        ]

        requests.decodeAsync(BaseStatusResponseModel.self,
                             method: .post,
                             url: URLs.markStoriesAsSeenUrl(),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }

    /// Get reels media feed.
    public func reelsMedia(_ feeds: [String], completionHandler: @escaping (Result<StoryReelsFeedModel, Error>) -> Void) {
        guard let storage = handler.response?.cache?.storage else {
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid `SessionCache` in `APIHandler.respone`. Log in again.")))
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
            return completionHandler(.failure(CustomErrors.runTimeError("Invalid request.")))
        }
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.igSignatureValue)

        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.igSignatureVersionKey: Headers.igSignatureVersionValue
        ]

        requests.decodeAsync(StoryReelsFeedModel.self,
                             method: .post,
                             url: URLs.getReelsMediaFeed(),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }

    func archive(completionHandler: @escaping (Result<StoryArchiveFeedModel, Error>) -> Void) {
        requests.decodeAsync(StoryArchiveFeedModel.self,
                             method: .get,
                             url: URLs.getStoryArchiveUrl(),
                             completionHandler: completionHandler)
    }
}
