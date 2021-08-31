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

public final class StoryHandler: Handler {
    /// Get the story feed.
    public func tray(completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        requests.request(Tray.self,
                         method: .get,
                         endpoint: Endpoint.Feed.reelsTray,
                         completion: completionHandler)
    }

    /// Get user's stories.
    public func by(user: User.Reference, completionHandler: @escaping (Result<TrayElement, Error>) -> Void) {
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache))
            }
            by(user: .primaryKey(pk), completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.by(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // load stories directly.
            requests.request(TrayElement.self,
                             method: .get,
                             endpoint: Endpoint.Feed.reelMedia.user(pk),
                             completion: completionHandler)
        }
    }

    /// Get reel feed.
    public func reelBy(user: User.Reference, completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache))
            }
            reelBy(user: .primaryKey(pk), completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.reelBy(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // load stories directly.
            requests.request(Tray.self,
                             method: .get,
                             endpoint: Endpoint.Feed.story.user(pk),
                             process: { Tray(rawResponse: $0.reel) },
                             completion: completionHandler)
        }
    }

    /// Get highlights.
    public func highlightsBy(user: User.Reference, completionHandler: @escaping (Result<Tray, Error>) -> Void) {
        switch user {
        case .me:
            // check for valid user.
            guard let pk = handler.user?.identity.primaryKey ?? Int(handler.response?.storage?.dsUserId ?? "invaild") else {
                return completionHandler(.failure(AuthenticationError.invalidCache))
            }
            highlightsBy(user: .primaryKey(pk), completionHandler: completionHandler)
        case .username:
            // fetch username.
            self.handler.users.user(user) { [weak self] in
                guard let handler = self else {
                    return completionHandler(.failure(GenericError.weakObjectReleased))
                }
                switch $0 {
                case .success(let user) where user.identity.primaryKey != nil:
                    handler.highlightsBy(user: .primaryKey(user.identity.primaryKey!), completionHandler: completionHandler)
                case .failure(let error): completionHandler(.failure(error))
                default: completionHandler(.failure(GenericError.custom("No user matching `username`.")))
                }
            }
        case .primaryKey(let pk):
            // load stories directly.
            requests.request(Tray.self,
                             method: .get,
                             endpoint: Endpoint.Highlights.tray.user(pk),
                             completion: completionHandler)
        }
    }

    /// Get story viewers.
    public func viewers(forStory storyId: String,
                        with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<User, StoryViewers>?,
                        completionHandler: @escaping PaginationCompletionHandler<User>) {
        pages.request(User.self,
                      page: StoryViewers.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Media.storyViewers.media(storyId).next($0.nextMaxId) },
                      splice: { $0.rawResponse.users.array?.compactMap(User.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Mark stories as seen.
    public func mark(stories: [Media],
                     with sourceId: String?,
                     asSeen seen: Bool,
                     completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
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
            let hash = try HMAC(key: Constants.igSignatureKey, variant: .sha256).authenticate(payload.bytes).toHexString()

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Constants.igSignatureVersionKey: Constants.igSignatureVersionValue
            ]

            requests.request(Status.self,
                             method: .post,
                             endpoint: Endpoint.Media.markAsSeen,
                             body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
        } catch { completionHandler(.failure(error)) }
    }

    /// Get reels media feed.
    public func reelsMedia(_ feeds: [String], completionHandler: @escaping (Result<[String: TrayElement], Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let supportedCapabilities = SupportedCapability.generate().map { [$0.name: $0.value] }
        let dynamicData: DynamicRequest = ["supported_capabilities_new": supportedCapabilities,
                                           "_uuid": handler!.settings.device.deviceGuid.uuidString,
                                           "_uid": storage.dsUserId,
                                           "_csrftoken": storage.csrfToken,
                                           "user_ids": feeds,
                                           "source": "feed_timeline"]

        guard let payload = try? String(data: dynamicData.data(), encoding: .utf8) else {
            return completionHandler(.failure(GenericError.custom("Invalid request.")))
        }
        do {
            let hash = try HMAC(key: Constants.igSignatureKey, variant: .sha256).authenticate(payload.bytes).toHexString()

            let signature = "\(hash).\(payload)"
            let body: [String: Any] = [
                Constants.igSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                Constants.igSignatureVersionKey: Constants.igSignatureVersionValue
            ]

            requests.request([String: TrayElement].self,
                             method: .post,
                             endpoint: Endpoint.Feed.reelsMedia,
                             body: .parameters(body),
                             process: { $0.reels.dictionary?.compactMapValues { TrayElement(rawResponse: $0) } ?? [:] },
                             completion: completionHandler)
        } catch { completionHandler(.failure(error)) }
    }

    /// Get reels archive.
    public func archive(with paginationParameters: PaginationParameters,
                        updateHandler: PaginationUpdateHandler<TrayArchive, AnyPaginatedResponse>?,
                        completionHandler: @escaping PaginationCompletionHandler<TrayArchive>) {
        pages.request(TrayArchive.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Archive.stories.next($0.nextMaxId) },
                      splice: { $0.rawResponse.items.array?.compactMap(TrayArchive.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }
}
