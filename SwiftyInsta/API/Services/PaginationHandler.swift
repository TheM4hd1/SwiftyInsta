//
//  PaginationHandler.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/19/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol PaginationProtocol {
    associatedtype Id: Hashable & LosslessStringConvertible
    var autoLoadMoreEnabled: Bool? { get }
    var moreAvailable: Bool? { get }
    var nextMaxId: Id? { get }
    var numResults: Int? { get }
}
public extension PaginationProtocol {
    var autoLoadMoreEnabled: Bool? { return nil }
    var moreAvailable: Bool? { return nil }
    var numResults: Int? { return nil }
}

public protocol NestedPaginationProtocol: PaginationProtocol {
    static var nextMaxIdPath: KeyPath<Self, Id?> { get }
}
public extension NestedPaginationProtocol {
    var nextMaxId: Id? { return self[keyPath: Self.nextMaxIdPath] }
}

struct PaginationHandler {
    /// Get all pages matching criteria.
    static func getPages<M>(_ result: M.Type,
                            for paginationParamaters: PaginationParameters,
                            at url: @escaping (PaginationParameters) throws -> URL,
                            updateHandler: PaginationResponse<M>?,
                            completionHandler: @escaping PaginationResponse<Result<[M]>>) where M: Decodable & PaginationProtocol {
        // check for valid pagination.
        guard paginationParamaters.canLoadMore, let handler = HandlerSettings.shared.httpHelper else {
            return completionHandler(Return.fail(error: nil, response: .fail, value: nil), paginationParamaters)
        }
        // to be populated with fetched data, but currently empty.
        var fetched: [M] = []
        
        // declare nested function to load current page.
        func getPage() {
            // obtain url.
            let endpoint: URL!
            do {
                endpoint = try url(paginationParamaters)
            } catch {
                completionHandler(Return.fail(error: error,
                                              response: fetched.isEmpty ? .ok : .fail,
                                              value: fetched),
                                   paginationParamaters)
                return
            }
            // fetch values.
            handler.sendAsync(method: .get,
                              url: endpoint,
                              body: [:],
                              header: [:]) { data, response, error in
                                guard error == nil else {
                                    completionHandler(Return.fail(error: error, response: .fail, value: fetched), paginationParamaters)
                                    return
                                }
                                guard let response = response, response.statusCode == 200, let data = data else {
                                    completionHandler(Return.fail(error: nil, response: .ok, value: fetched), paginationParamaters)
                                    return
                                }
                                // we loaded one more page.
                                paginationParamaters.loadedPages += 1
                                // decode response.
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .convertFromSnakeCase
                                do {
                                    let model = try decoder.decode(M.self, from: data)
                                    // append to model and ask for next.
                                    updateHandler?(model, paginationParamaters)
                                    fetched.append(model)
                                    guard paginationParamaters.canLoadMore else {
                                        return completionHandler(Return.success(value: fetched), paginationParamaters)
                                    }
                                    // load more.
                                    paginationParamaters.nextMaxId = model.nextMaxId.flatMap { String($0) } ?? ""
                                    guard paginationParamaters.nextMaxId != nil else {
                                        return completionHandler(Return.success(value: fetched), paginationParamaters)
                                    }
                                    getPage()
                                } catch {
                                    completionHandler(Return.fail(error: error, response: .ok, value: fetched), paginationParamaters)
                                }
                                
            }
        }
        // exhaust pages.
        getPage()
    }
}
