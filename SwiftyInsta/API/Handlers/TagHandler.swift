//
//  File.swift
//  
//
//  Created by Zeeshan Ahmed on 06/07/2020.
//

import Foundation
public final class TagHandler: Handler {
    /// Search for tags matching the query.
    public func search(forTagsMatching query: String, completionHandler: @escaping (Result<[Tag], Error>) -> Void) {
        guard let storage = handler.response?.storage else {
            return completionHandler(.failure(GenericError.custom("Invalid `Authentication.Response` in `APIHandler.respone`. Log in again.")))
        }
        let headers = [Headers.timeZoneOffsetKey: Headers.timeZoneOffsetValue,
                       Headers.countKey: Headers.countValue,
                       Headers.rankTokenKey: storage.rankToken]

        pages.request(Tag.self,
                      page: AnyPaginatedResponse.self,
                      with: .init(maxPagesToLoad: 1),
                      endpoint: { _ in Endpoint.Tags.search.q(query) },
                      headers: { _ in headers },
                      splice: { $0.rawResponse.results.array?.compactMap(Tag.init) ?? [] },
                      update: nil) { result, _ in
                        completionHandler(result)
        }
    }
}
