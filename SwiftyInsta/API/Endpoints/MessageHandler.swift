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
        pages.parse(Thread.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: paginationParameters,
                    at: { try Endpoints.Direct.inbox.url(with: ["max_id": $0.nextMaxId]) },
                    processingHandler: { $0.rawResponse.inbox.threads.array?.map(Thread.init) ?? [] },
                    updateHandler: updateHandler,
                    completionHandler: completionHandler)
    }

    /// Send message to user(s) in thred.
    public func send(_ text: String,
                     to receipients: Recipient.Reference,
                     completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        var body = ["text": text,
                    "action": "send_item"]
        switch receipients {
        case .users(let users): body["receipient_users"] = "[[\(users.map(String.init).joined(separator: ","))]]"
        case .thread(let thread): body["thread_ids"] = "[\(thread)]"
        }

        requests.decode(Status.self,
                        method: .get,
                        url: Result { try Endpoints.Direct.text.url() },
                        body: .parameters(body)) { completionHandler($0.map { $0.state == .ok }) }
    }

    /// Get thread by id.
    public func `in`(thread: String, completionHandler: @escaping (Result<Thread, Error>) -> Void) {
        requests.parse(Thread.self,
                       method: .get,
                       url: Result { try Endpoints.Direct.thread.resolving(thread).url() },
                       completionHandler: completionHandler)
    }

    /// Get recent receipients.
    public func recent(completionHandler: @escaping (Result<[Recipient], Error>) -> Void) {
        pages.parse(Recipient.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: .init(maxPagesToLoad: 1),
                    at: { _ in try Endpoints.Direct.recentRecipients.url() },
                    processingHandler: { $0.rawResponse.recentRecipients.array?.map(Recipient.init) ?? [] },
                    updateHandler: nil) { result, _ in
                        completionHandler(result)
        }
    }

    /// Get ranked receipients.
    public func ranked(completionHandler: @escaping (Result<[Recipient], Error>) -> Void) {
        pages.parse(Recipient.self,
                    paginatedResponse: AnyPaginatedResponse.self,
                    with: .init(maxPagesToLoad: 1),
                    at: { _ in try Endpoints.Direct.rankedRecipients.url() },
                    processingHandler: { $0.rawResponse.rankedRecipients.array?.map(Recipient.init) ?? [] },
                    updateHandler: nil) { result, _ in
                        completionHandler(result)
        }
    }
}
