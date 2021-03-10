//
//  MessageHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi Makhdumi on 11/23/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public final class MessageHandler: Handler {
    /// Get the user's inbox.
    public func inbox(with paginationParameters: PaginationParameters,
                      updateHandler: PaginationUpdateHandler<Thread, AnyPaginatedResponse>?,
                      completionHandler: @escaping PaginationCompletionHandler<Thread>) {
        pages.request(Thread.self,
                      page: AnyPaginatedResponse.self,
                      with: paginationParameters,
                      endpoint: { Endpoint.Direct.inbox.next($0.nextMaxId) },
                      next: { $0.inbox.oldestCursor.string },
                      splice: { $0.rawResponse.inbox.threads.array?.compactMap(Thread.init) ?? [] },
                      update: updateHandler,
                      completion: completionHandler)
    }

    /// Send message to user(s) in thred.
    public func send(_ text: String,
                     to receipients: Recipient.Reference,
                     completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        var body = ["text": text,
                    "action": "send_item"]
        switch receipients {
        case .users(let users): body["recipient_users"] = "[[\(users.map(String.init).joined(separator: ","))]]"
        case .thread(let thread): body["thread_ids"] = "[\(thread)]"
        }

        requests.request(Status.self,
                         method: .post,
                         endpoint: Endpoint.Direct.text,
                         body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Get thread by id.
    public func `in`(thread: String, completionHandler: @escaping (Result<Thread, Error>) -> Void) {
        requests.request(Thread.self,
                         method: .get,
                         endpoint: Endpoint.Direct.thread.thread(thread),
                         completion: completionHandler)
    }

    /// Get recent receipients.
    public func recent(completionHandler: @escaping (Result<[Recipient], Error>) -> Void) {
        pages.request(Recipient.self,
                      page: AnyPaginatedResponse.self,
                      with: .init(maxPagesToLoad: 1),
                      endpoint: { _ in Endpoint.Direct.recentRecipients },
                      splice: { $0.rawResponse.recentRecipients.array?.compactMap(Recipient.init) ?? [] },
                      update: nil) { result, _ in
                        completionHandler(result)
        }
    }

    /// Get ranked receipients.
    public func ranked(completionHandler: @escaping (Result<[Recipient], Error>) -> Void) {
        pages.request(Recipient.self,
                      page: AnyPaginatedResponse.self,
                      with: .init(maxPagesToLoad: 1),
                      endpoint: { _ in Endpoint.Direct.rankedRecipients },
                      splice: { $0.rawResponse.rankedRecipients.array?.compactMap(Recipient.init) ?? [] },
                      update: nil) { result, _ in
                        completionHandler(result)
        }
    }
}
