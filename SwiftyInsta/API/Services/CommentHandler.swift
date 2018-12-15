//
//  CommentHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol CommentHandlerProtocol {
    func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws
    func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws
    func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws
}

class CommentHandler: CommentHandlerProtocol {
    static let shared = CommentHandler()
    
    private init() {
        
    }
    
    func getMediaComments(mediaId: String, paginationParameter: PaginationParameters, completion: @escaping (Result<[MediaCommentsResponseModel]>) -> ()) throws {
        getCommentList(for: try URLs.getComments(for: mediaId), mediaId: mediaId, list: [], paginationParameter: paginationParameter) { (value) in
            completion(Return.success(value: value))
        }
    }
    
    fileprivate func getCommentList(for url: URL, mediaId: String, list: [MediaCommentsResponseModel], paginationParameter: PaginationParameters, completion: @escaping ([MediaCommentsResponseModel]) -> ()) {
        if paginationParameter.pagesLoaded == paginationParameter.maxPagesToLoad {
            completion(list)
        } else {
            var _paginationParameter = paginationParameter
            _paginationParameter.pagesLoaded += 1
            HandlerSettings.shared.httpHelper!.sendAsync(method: .get, url: url, body: [:], header: [:]) { [weak self] (data, response, error) in
                if error != nil {
                    completion(list)
                } else {
                    if let data = data {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        var commentList = list
                        do {
                            let newItem = try decoder.decode(MediaCommentsResponseModel.self, from: data)
                            commentList.append(newItem)
                            if newItem.hasMoreComments! && newItem.nextMaxId != nil {
                                _paginationParameter.nextId = newItem.nextMaxId!
                                let url = try! URLs.getComments(for: mediaId, maxId: _paginationParameter.nextId)
                                self!.getCommentList(for: url, mediaId: mediaId, list: commentList, paginationParameter: _paginationParameter, completion: { (result) in
                                    completion(result)
                                })
                            } else {
                                completion(commentList)
                            }
                        } catch {
                            completion(list)
                        }
                    }
                }
            }
        }
    }
    
    func addComment(mediaId: String, comment text: String, completion: @escaping (Result<CommentResponse>) -> ()) throws {
        let content = [
            "user_breadcrumb": String(Date().millisecondsSince1970),
            "idempotence_token": UUID.init().uuidString,
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken,
            "comment_text": text,
            "containermodule": "comments_feed_timeline",
            "radio_type": "wifi-none"
        ]
        
        let encoder = JSONEncoder()
        let payload = String(data: try! encoder.encode(content), encoding: .utf8)!
        let hash = payload.hmac(algorithm: .SHA256, key: Headers.HeaderIGSignatureValue)
        // Creating Post Request Body
        let signature = "\(hash).\(payload)"
        let body: [String: Any] = [
            Headers.HeaderIGSignatureKey: signature.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
            Headers.HeaderIGSignatureVersionKey: Headers.HeaderIGSignatureVersionValue
        ]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getPostCommentUrl(mediaId: mediaId), body: body, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(CommentResponse.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func deleteComment(mediaId: String, commentPk: String, completion: @escaping (Bool) -> ()) throws {
        let content = [
            "_uuid": HandlerSettings.shared.device!.deviceGuid.uuidString,
            "_uid": String(HandlerSettings.shared.user!.loggedInUser.pk!),
            "_csrftoken": HandlerSettings.shared.user!.csrfToken
        ]
        
        HandlerSettings.shared.httpHelper!.sendAsync(method: .post, url: try URLs.getDeleteCommentUrl(mediaId: mediaId, commentId: commentPk), body: content, header: [:]) { (data, response, error) in
            if error != nil {
                completion(false)
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let status = try decoder.decode(BaseStatusResponseModel.self, from: data)
                        completion(status.isOk())
                    } catch {
                        completion(false)
                    }
                }
            }
        }
    }
}
