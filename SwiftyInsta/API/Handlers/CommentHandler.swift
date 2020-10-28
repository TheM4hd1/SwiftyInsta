//
//  CommentHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import CryptoSwift
import Foundation

public final class CommentHandler: Handler {
    /// Fetch all comments for media.
    public func all(forMedia mediaId: String,
                    with paginationParameters: PaginationParameters,
                    updateHandler: PaginationUpdateHandler<Comment, MediaComments>?,
                    completionHandler: @escaping PaginationCompletionHandler<Comment>) {
        pages.request(Comment.self,
                      page: MediaComments.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Media.comments.media(mediaId).next($0.nextMaxId) },
                      splice: { $0.rawResponse.comments.array?.compactMap(Comment.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Add comment to media.
    public func add(_ comment: String, to mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                       "_uid": storage.dsUserId,
                       "_csrftoken": storage.csrfToken,
                       "is_carousel_bumped_post": "false",
                       "idempotence_token": UUID.init().uuidString,
                       "comment_text": comment,
                       "container_module": "comments_v2_feed_timeline",
                       "inventory_source": "media_or_ad",
                       "delivery_class": "organic",
                       "carousel_index": "0"]

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Media.postComment.media(mediaId),
                         body: .payload(body)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Delete a comment.
    public func delete(comment commentId: String, in mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "comment_ids_to_delete": commentId]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Media.deleteComment.media(mediaId),
                         body: .payload(body),
                         completion: { completionHandler($0.map { $0.state == .ok }) })
    }

    /// Report a comment.
    public func report(comment commentId: String, in mediaId: String, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let body = ["_uuid": handler.settings.device.deviceGuid.uuidString,
                    "_uid": storage.dsUserId,
                    "_csrftoken": storage.csrfToken,
                    "reason": "1",
                    "comment_id": commentId,
                    "media_id": mediaId]
        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Media.reportComment.comment(commentId).media(mediaId),
                         body: .parameters(body),
                         completion: { completionHandler($0.map { $0.state == .ok }) })
    }
}
