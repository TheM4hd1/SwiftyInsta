//
//  APIHandler.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation
import KeychainSwift

/// Do not use this directly.
public class Handler {
    weak var handler: APIHandler!
    init(handler: APIHandler) { self.handler = handler }

    /// The requests helper.
    var requests: HTTPHelper { return handler.requests }
    /// The pagination helper.
    var pages: PaginationHelper { return handler.pages }
}

/// The `Instagram Private API` client.
public class APIHandler {
    /// A struct used to initialize `APIHandler`s.
    public struct Settings {
        /// A struct used to manage `DispatchQueue`s.
        public struct Queues {
            /// The queue used to prepare requests. Defaults to `DispatchQueue.main`.
            public var request: DispatchQueue
            /// The queue used for parsing and heavy lifting. Defaults to `DispatchQueue.global(qos: .userInitiated)`.
            public var working: DispatchQueue
            /// The queue used to deliver responses. Defaults to `DispatchQueue.main`.
            public var response: DispatchQueue

            public init(request: DispatchQueue = .main,
                        working: DispatchQueue = .global(qos: .userInitiated),
                        response: DispatchQueue = .main) {
                self.request = request
                self.working = working
                self.response = response
            }
        }

        /// The delay. Defaults to `1...2`. `0...0` for no delay.
        public var delay: ClosedRange<Double>
        /// The queue used to deliver responses. Defaults to `DispatchQueue.global(qos: .utility)`.
        public var queues: Queues
        /// The device. Defaults to a random device.
        public var device: Device
        /// The url session. Defaults to `.shared`.
        public var session: URLSession
        /// The default headers. Defaults to `[:]`.
        var headers: [String: String] = [:]

        public init(delay: ClosedRange<Double> = 1...2,
                    queues: Queues = .init(),
                    device: Device? = nil,
                    session: URLSession = .shared) {
            self.delay = delay
            self.queues = queues
            self.device = device ?? AnyDevice.random()
            self.session = session
        }
    }

    /// The settings.
    public var settings: Settings
    /// The login response.
    public var response: Authentication.Response?
    /// The authenticated user.
    public var user: User? { return response?.storage?.user }

    // MARK: Init
    /// Create an instance of `APIHandler`.
    public init(with settings: Settings = .init()) {
        self.settings = settings
    }

    // MARK: Authentication
    /// Authenticate with the selected login method.
    public func authenticate(with request: Authentication.Request,
                             completionHandler: @escaping (Result<(Authentication.Response, APIHandler), Error>) -> Void) {
        switch request {
        case .cache(let cache):
            authentication.authenticate(cache: cache) { [weak self] response in
                guard let handler = self else { return completionHandler(.failure(GenericError.custom("`weak` reference was released."))) }
                handler.settings.queues.response.async {
                    completionHandler(response.map { ($0, handler) })
                }
            }
        case .user(let credentials):
            authentication.authenticate(user: credentials, completionHandler: completionHandler)
        #if canImport(WebKit)
        case .webView(let webView):
            webView.authenticate { [weak self] in
                guard let handler = self else { return completionHandler(.failure(GenericError.weakObjectReleased)) }
                // check for cookies.
                switch $0 {
                case .failure(let error): completionHandler(.failure(error))
                case .success(let instagramCookies):
                    let data = instagramCookies.filter({ $0.domain.contains(".instagram.com") })
                    let filtered = data.filter { $0.name == "ds_user_id" || $0.name == "csrftoken" || $0.name == "sessionid" }
                    guard filtered.count >= 3 else {
                        return handler.settings.queues.response.async {
                            completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` response.")))
                        }
                    }
                    // prepare cache.
                    guard let dsUserId = filtered.first(where: { $0.name == "ds_user_id" })?.value,
                        let csrfToken = filtered.first(where: { $0.name == "csrftoken" })?.value,
                        let sessionId = filtered.first(where: { $0.name == "sessionid" })?.value else {
                            return completionHandler(.failure(GenericError.custom("Invalid cookies.")))
                    }
                    let rankToken = dsUserId+"_"+handler.settings.device.phoneGuid.uuidString
                    let cache = Authentication.Response(device: handler.settings.device,
                                                        storage: .init(dsUserId: dsUserId,
                                                                       csrfToken: csrfToken,
                                                                       sessionId: sessionId,
                                                                       rankToken: rankToken,
                                                                       user: nil),
                                                        data: data.data)
                    handler.authenticate(with: .cache(cache), completionHandler: completionHandler)
                }
            }
        #endif
        }
    }

    /// Log out.
    public func invalidate(completionHandler: @escaping (Result<Bool, Error>) -> Void) throws {
        let key = response?.storage?.dsUserId
        authentication.invalidate { [weak self] in
            switch $0 {
            case .failure(let error): completionHandler(.failure(error))
            case .success(let success) where success:
                self?.response = nil
                // remove cache.
                if let key = key { KeychainSwift().delete(key) }
                completionHandler(.success(success))
            default: completionHandler(.success(false))
            }
        }
    }

    // MARK: Helpers
    /// Accessory for `HttpHelper(handler: self)`.
    internal lazy var requests: HTTPHelper = .init(handler: self)
    /// Accessory for `PaginationHelper(handler: self)`.
    internal lazy var pages: PaginationHelper = .init(handler: self)

    // MARK: Handlers
    /// `AuthenticationHandler` endpoints manager.
    lazy var authentication: AuthenticationHandler = .init(handler: self)
    /// `UserHandler` endpoints manager.
    public private(set) lazy var users: UserHandler = .init(handler: self)
    /// `CommentHandler` endpoints manager.
    public private(set) lazy var comments: CommentHandler = .init(handler: self)
    /// `FeedHandler` endpoints manager.
    public private(set) lazy var feeds: FeedHandler = .init(handler: self)
    /// `MediaHandler` endpoints manager.
    public private(set) lazy var media: MediaHandler = .init(handler: self)
    /// `MessageHandler` endpoints manager.
    public private(set) lazy var messages: MessageHandler = .init(handler: self)
    /// `ProfileHandler` endpoints manager.
    public private(set) lazy var profile: ProfileHandler = .init(handler: self)
    /// `StoryHandler` endpoints manager.
    public private(set) lazy var stories: StoryHandler = .init(handler: self)
}
