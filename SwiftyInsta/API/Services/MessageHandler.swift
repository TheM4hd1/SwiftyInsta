//
//  MessageHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public protocol MessageHandlerProtocol {
    func getDirectInbox(completion: @escaping (InstagramResult<DirectInboxModel>) -> ()) throws
    func sendDirect(to userId: String, in threadId: String, with text: String, completion: @escaping (InstagramResult<DirectSendMessageResponseModel>) -> ()) throws
    func getDirectThreadById(threadId: String, completion: @escaping (InstagramResult<ThreadModel>) -> ()) throws
    func getRecentDirectRecipients(completion: @escaping (InstagramResult<RecentRecipientsModel>) -> ()) throws
    func getRankedDirectRecipients(completion: @escaping (InstagramResult<RankedRecipientsModel>) -> ()) throws
}

public class MessageHandler: Handler {
    func getDirectInbox(completion: @escaping (InstagramResult<DirectInboxModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getDirectInbox(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(DirectInboxModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func sendDirect(to userIds: String, in threadIds: String, with text: String, completion: @escaping (InstagramResult<DirectSendMessageResponseModel>) -> ()) throws {
        var content = [
            "text": text,
            "action": "send_item"
        ]
        
        if !userIds.isEmpty {
            content.updateValue("[[\(userIds)]]", forKey: "recipient_users")
        } else {
            throw CustomErrors.unExpected("Please provide at least one recipient.")
        }
        
        if !threadIds.isEmpty {
            content.updateValue("[\(threadIds)]", forKey: "thread_ids")
        }
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .post, url: try URLs.getDirectSendTextMessage(), body: content, header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(DirectSendMessageResponseModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func getDirectThreadById(threadId: String, completion: @escaping (InstagramResult<ThreadModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getDirectThread(id: threadId), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if response?.statusCode == 404 {
                        let error = CustomErrors.unExpected("thread not found.")
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    } else {
                        do {
                            let value =  try decoder.decode(ThreadModel.self, from: data)
                            completion(Return.success(value: value))
                        } catch {
                            completion(Return.fail(error: error, response: .ok, value: nil))
                        }
                    }
                }
            }
        }
    }
    
    func getRecentDirectRecipients(completion: @escaping (InstagramResult<RecentRecipientsModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getRecentDirectRecipients(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(RecentRecipientsModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
    
    func getRankedDirectRecipients(completion: @escaping (InstagramResult<RankedRecipientsModel>) -> ()) throws {
        guard let httpHelper = HandlerSettings.shared.httpHelper else {return}
        httpHelper.sendAsync(method: .get, url: try URLs.getRankedDirectRecipients(), body: [:], header: [:]) { (data, response, error) in
            if let error = error {
                completion(Return.fail(error: error, response: .fail, value: nil))
            } else {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let value = try decoder.decode(RankedRecipientsModel.self, from: data)
                        completion(Return.success(value: value))
                    } catch {
                        completion(Return.fail(error: error, response: .ok, value: nil))
                    }
                }
            }
        }
    }
}
