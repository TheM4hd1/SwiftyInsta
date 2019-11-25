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
        var copy = self
        copy.endpoint = copy.endpoint.filling(placeholder, with: string) as! Endpoint
        return copy
    }
    /// Query.
    public func query<L>(_ items: [String: L]) -> LosselessEndpointRepresentable! where L: LosslessStringConvertible {
        var copy = self
        copy.items = copy.items.merging(items.mapValues(String.init), uniquingKeysWith: { _, rhs in rhs })
        return copy
    }
    /// Append path.
    public func appending(_ path: String) -> LosselessEndpointRepresentable! {
        var copy = self
        copy.endpoint = copy.endpoint.appending(path) as! Endpoint
        return copy
    }
    /// Description.
    public var description: String {
        return "(Query:"+items.description+")"+endpoint.description
    }
}
