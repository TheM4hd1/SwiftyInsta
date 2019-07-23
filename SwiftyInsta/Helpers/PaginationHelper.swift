//
//  PaginationHelper.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/19/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

protocol PaginationProtocol {
    associatedtype Id: Hashable & LosslessStringConvertible
    var autoLoadMoreEnabled: Bool? { get }
    var moreAvailable: Bool? { get }
    var nextMaxId: Id? { get }
    var numResults: Int? { get }
}
extension PaginationProtocol {
    var autoLoadMoreEnabled: Bool? { return nil }
    var moreAvailable: Bool? { return nil }
    var numResults: Int? { return nil }
}

protocol NestedPaginationProtocol: PaginationProtocol {
    static var nextMaxIdPath: KeyPath<Self, Id?> { get }
}
extension NestedPaginationProtocol {
    var nextMaxId: Id? { return self[keyPath: Self.nextMaxIdPath] }
}

public typealias PaginationUpdateHandler<R> = (_ update: R, _ nextParameters: PaginationParameters, _ runningResponse: [R]) -> Void
public typealias PaginationCompletionHandler<R> = (_ response: Result<[R], Error>, _ nextParameters: PaginationParameters) -> Void

class PaginationHelper: Handler {
    /// Get all pages matching criteria.
    func fetch<M>(_ result: M.Type,
                  with paginationParamaters: PaginationParameters,
                  at url: @escaping (PaginationParameters) throws -> URL,
                  body: ((PaginationParameters) -> HttpHelper.Body?)? = nil,
                  headers: ((PaginationParameters) -> [String: String])? = nil,
                  delay: ClosedRange<Double>? = nil,
                  updateHandler: PaginationUpdateHandler<M>?,
                  completionHandler: @escaping PaginationCompletionHandler<M>) where M: Decodable & PaginationProtocol {
        // check for valid pagination.
        guard paginationParamaters.canLoadMore else {
            return completionHandler(.failure(CustomErrors.runTimeError("Can't load more.")), paginationParamaters)
        }
        guard let handler = handler else {
            return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParamaters)
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
            handler.requests.decodeAsync(M.self,
                                         method: .get,
                                         url: endpoint,
                                         body: body?(paginationParamaters),
                                         headers: headers?(paginationParamaters) ?? [:],
                                         deliverOnResponseQueue: false,
                                         delay: delay) { [weak self] in
                guard let handler = self?.handler else {
                    return completionHandler(.failure(CustomErrors.weakReferenceReleased), paginationParamaters)
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
