//
//  PaginationHelper.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/19/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol PaginationProtocol {
    associatedtype Identifier: Hashable & LosslessStringConvertible
    var autoLoadMoreEnabled: Bool? { get }
    var moreAvailable: Bool? { get }
    var nextMaxId: Identifier? { get }
    var numResults: Int? { get }
}
public extension PaginationProtocol {
    var autoLoadMoreEnabled: Bool? { return nil }
    var moreAvailable: Bool? { return nil }
    var numResults: Int? { return nil }
}

public protocol NestedPaginationProtocol: PaginationProtocol {
    static var nextMaxIdPath: KeyPath<Self, Identifier?> { get }
}
public extension NestedPaginationProtocol {
    var nextMaxId: Identifier? { return self[keyPath: Self.nextMaxIdPath] }
}

protocol PaginatedResponse: ParsedResponse {
    var nextMaxId: String? { get }
}
extension PaginatedResponse {
    /// The `nextMaxId`.
    var nextMaxId: String? { return rawResponse.nextMaxId.string }
}
public struct AnyPaginatedResponse: PaginatedResponse {
    /// The `rawResponse`.
    public var rawResponse: DynamicResponse

    /// Init.
    public init(rawResponse: DynamicResponse) {
        self.rawResponse = rawResponse
    }

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
}

public typealias PaginationUpdateHandler<R, P> = (
        _ update: P,
        _ inserting: [R],
        _ nextParameters: PaginationParameters,
        _ runningResponse: [R]
    ) -> Void
public typealias LegacyPaginationUpdateHandler<R> = (_ update: R, _ nextParameters: PaginationParameters, _ runningResponse: [R]) -> Void
public typealias PaginationCompletionHandler<R> = (_ response: Result<[R], Error>, _ nextParameters: PaginationParameters) -> Void

class PaginationHelper: Handler {
    /// Get all pages matching criteria.
    func parse<M, P>(_ result: M.Type,
                     paginatedResponse: P.Type,
                     with paginationParamaters: PaginationParameters,
                     at url: @escaping (PaginationParameters) throws -> URL,
                     body: ((PaginationParameters) -> HTTPHelper.Body?)? = nil,
                     headers: ((PaginationParameters) -> [String: String])? = nil,
                     delay: ClosedRange<Double>? = nil,
                     paginationHandler: @escaping (P) -> String? = { $0.rawResponse.nextMaxId.string },
                     processingHandler: @escaping (P) -> [M],
                     updateHandler: PaginationUpdateHandler<M, P>?,
                     completionHandler: @escaping PaginationCompletionHandler<M>) where M: ParsedResponse, P: ParsedResponse {
        // check for valid pagination.
        guard paginationParamaters.canLoadMore else {
            return completionHandler(.failure(GenericError.custom("Can't load more.")), paginationParamaters)
        }
        guard let handler = handler else {
            return completionHandler(.failure(GenericError.weakObjectReleased), paginationParamaters)
        }

        var fetched: [M] = []
        // declare nested function to load current page.
        func getPage() {
            // obtain url.
            let endpoint: URL!
            do {
                endpoint = try url(paginationParamaters)
            } catch {
                return handler.settings.queues.response.async {
                    completionHandler(.failure(error), paginationParamaters)
                }
            }
            // fetch values.
            handler.requests.parse(paginatedResponse,
                                   method: .get,
                                   url: .success(endpoint),
                                   body: body?(paginationParamaters),
                                   headers: headers?(paginationParamaters) ?? [:],
                                   deliverOnResponseQueue: false,
                                   delay: delay,
                                   processingHandler: { P(rawResponse: $0) }) { [weak self] in
                                    guard let handler = self?.handler else {
                                            return completionHandler(.failure(GenericError.weakObjectReleased), paginationParamaters)
                                        }
                                        switch $0 {
                                        case .success(let decoded):
                                            // increase pagination parameters.
                                            paginationParamaters.loadedPages += 1
                                            let processed = processingHandler(decoded)
                                            fetched.append(contentsOf: processed)
                                            // notify.
                                            handler.settings.queues.response.async {
                                                updateHandler?(decoded, processed, paginationParamaters, fetched)
                                            }
                                            // load more.
                                            guard paginationParamaters.canLoadMore else {
                                                return handler.settings.queues.response.async {
                                                    completionHandler(.success(fetched), paginationParamaters)
                                                }
                                            }
                                            paginationParamaters.nextMaxId = paginationHandler(decoded)
                                            guard !(paginationParamaters.nextMaxId ?? "").isEmpty else {
                                                return handler.settings.queues.response.async {
                                                    completionHandler(.success(fetched), paginationParamaters)
                                                }
                                            }
                                            getPage()
                                        case .failure(let error): completionHandler(.failure(error), paginationParamaters)
                                        }
            }
        }
        // exhaust pages.
        getPage()
    }
    /// Get all pages matching criteria.
    func decode<M>(_ result: M.Type,
                   with paginationParamaters: PaginationParameters,
                   at url: @escaping (PaginationParameters) throws -> URL,
                   body: ((PaginationParameters) -> HTTPHelper.Body?)? = nil,
                   headers: ((PaginationParameters) -> [String: String])? = nil,
                   delay: ClosedRange<Double>? = nil,
                   updateHandler: LegacyPaginationUpdateHandler<M>?,
                   completionHandler: @escaping PaginationCompletionHandler<M>) where M: Decodable & PaginationProtocol {
        // check for valid pagination.
        guard paginationParamaters.canLoadMore else {
            return completionHandler(.failure(GenericError.custom("Can't load more.")), paginationParamaters)
        }
        guard let handler = handler else {
            return completionHandler(.failure(GenericError.weakObjectReleased), paginationParamaters)
        }

        var fetched: [M] = []
        // declare nested function to load current page.
        func getPage() {
            // obtain url.
            let endpoint: URL!
            do {
                endpoint = try url(paginationParamaters)
            } catch {
                return handler.settings.queues.response.async {
                    completionHandler(.failure(error), paginationParamaters)
                }
            }
            // fetch values.
            handler.requests.decode(M.self,
                                    method: .get,
                                    url: endpoint,
                                    body: body?(paginationParamaters),
                                    headers: headers?(paginationParamaters) ?? [:],
                                    deliverOnResponseQueue: false,
                                    delay: delay) { [weak self] in
                                        guard let handler = self?.handler else {
                                            return completionHandler(.failure(GenericError.weakObjectReleased), paginationParamaters)
                                        }
                                        switch $0 {
                                        case .success(let decoded):
                                            // increase pagination parameters.
                                            paginationParamaters.loadedPages += 1
                                            fetched.append(decoded)
                                            // notify.
                                            handler.settings.queues.response.async {
                                                updateHandler?(decoded, paginationParamaters, fetched)
                                            }
                                            // load more.
                                            guard paginationParamaters.canLoadMore else {
                                                return handler.settings.queues.response.async {
                                                    completionHandler(.success(fetched), paginationParamaters)
                                                }
                                            }
                                            paginationParamaters.nextMaxId = decoded.nextMaxId.flatMap { String($0) }
                                            guard !(paginationParamaters.nextMaxId ?? "").isEmpty else {
                                                return handler.settings.queues.response.async {
                                                    completionHandler(.success(fetched), paginationParamaters)
                                                }
                                            }
                                            getPage()
                                        case .failure(let error): completionHandler(.failure(error), paginationParamaters)
                                        }
            }
        }
        // exhaust pages.
        getPage()
    }
}
