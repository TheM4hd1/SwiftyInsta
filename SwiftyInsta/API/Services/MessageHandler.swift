//
//  MessageHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public enum MessageRecipients {
    case users([Int])
    case thread(String)
}

public class MessageHandler: Handler {
    /// Get the user's inbox.
    public func inbox(completionHandler: @escaping (Result<DirectInboxModel, Error>) -> Void) {
        requests.decodeAsync(DirectInboxModel.self,
                             method: .get,
                             url: try! URLs.getDirectSendTextMessage(),
                             completionHandler: completionHandler)
    }

    /// Send message to user(s) in thred.
    public func send(_ text: String,
                     to receipients: MessageRecipients,
                     completionHandler: @escaping (Result<DirectSendMessageResponseModel, Error>) -> Void) {
        var body = ["text": text,
                    "action": "send_item"]
        switch receipients {
        case .users(let users): body["receipient_users"] = "[[\(users.map(String.init).joined(separator: ","))]]"
        case .thread(let thread): body["thread_ids"] = "[\(thread)]"
        }
        
        requests.decodeAsync(DirectSendMessageResponseModel.self,
                             method: .get,
                             url: try! URLs.getDirectSendTextMessage(),
                             body: .parameters(body),
                             completionHandler: completionHandler)
    }
    
    /// Get thread by id.
    public func `in`(thread: String, completionHandler: @escaping (Result<ThreadModel, Error>) -> Void) {
        requests.decodeAsync(ThreadModel.self,
                             method: .get,
                             url: try! URLs.getDirectThread(id: thread),
                             completionHandler: completionHandler)
    }

    /// Get recent receipients.
    public func recent(completionHandler: @escaping (Result<RecentRecipientsModel, Error>) -> Void) {
        requests.decodeAsync(RecentRecipientsModel.self,
                             method: .get,
                             url: try! URLs.getRecentDirectRecipients(),
                             completionHandler: completionHandler)
    }

    /// Get ranked receipients.
    public func ranked(completionHandler: @escaping (Result<RankedRecipientsModel, Error>) -> Void) {
        requests.decodeAsync(RankedRecipientsModel.self,
                             method: .get,
                             url: try! URLs.getRankedDirectRecipients(),
                             completionHandler: completionHandler)
    }
}
