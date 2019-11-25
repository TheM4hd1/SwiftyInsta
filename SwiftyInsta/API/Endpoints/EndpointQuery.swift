//
//  EndpointQuery.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 25/11/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `struct` holding reference to a specific `Endpoint` query.
public struct EndpointQuery<Endpoint: LosselessEndpointRepresentable>: LosselessEndpointRepresentable {
    /// The endpoint.
    public var endpoint: Endpoint
    /// The query items.
    public var items: [String: String]

    // MARK: Representable
    /// The `URLComponents`.
    public var components: URLComponents? {
        var components = endpoint.components
        components?.queryItems = items.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components
    }
    /// The placeholders.
    public var placeholders: [String]? { return endpoint.placeholders }
    /// Fill a placeholder.
    public func filling(_ placeholder: String, with string: String) -> LosselessEndpointRepresentable! {
        guard let endpoint = self.endpoint.filling(placeholder, with: string) as? Endpoint else {
            fatalError("Invalid endpoint.")
        }
        return EndpointQuery(endpoint: endpoint, items: items)
    }
    /// Query.
    public func query<L>(_ items: [String: L]) -> LosselessEndpointRepresentable! where L: LosslessStringConvertible {
        let items = self.items.merging(items.mapValues(String.init), uniquingKeysWith: { _, rhs in rhs })
        return EndpointQuery(endpoint: endpoint, items: items)
    }
    /// Append path.
    public func appending(_ path: String) -> LosselessEndpointRepresentable! {
        guard let endpoint = self.endpoint.appending(path) as? Endpoint else {
            fatalError("Invalid endpoint.")
        }
        return EndpointQuery(endpoint: endpoint, items: items)
    }
    /// Description.
    public var description: String {
        return "(Query:"+items.description+")"+endpoint.description
    }
}
