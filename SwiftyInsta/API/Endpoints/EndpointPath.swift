//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 25/11/2019.
//

import Foundation

/// An `enum` describing possible `URL`s.
public enum EndpointPath {
    /// Starting with `https://i.instagram.com/api/v1`.
    case v1(String)
    /// Starting with `https://i.instagram.com/api/v2`.
    case v2(String)
    /// Starting with `https://www.instagram.com`.
    case generic(String)
}
/// Accessories.
extension EndpointPath: LosselessEndpointRepresentable {
    // MARK: Placeholders
    /// The holders in path.
    public var placeholders: [String]? {
        let path = self.endpointPath
        let expression = try? NSRegularExpression(pattern: "\\{.+?\\}")
        return expression?.matches(in: path,
                                   options: [],
                                   range: .init(location: 0, length: path.utf16.count))
            .compactMap { Range($0.range, in: path).flatMap { String(path[$0]) }}
    }
    /// Fill a placeholder.
    public func filling(_ placeholder: String, with string: String) -> LosselessEndpointRepresentable! {
        var former = placeholder
        if !former.hasPrefix("{") { former = "{"+former }
        if !former.hasSuffix("}") { former = former+"}" }
        return EndpointPath(rawValue: rawValue.replacingOccurrences(of: former, with: string))
    }
    
    // MARK: Query
    /// Query.
    public func query<L>(_ items: [String: L]) -> LosselessEndpointRepresentable! where L: LosslessStringConvertible {
        return EndpointQuery(endpoint: self, items: items.mapValues(String.init))
    }
    /// Append path.
    public func appending(_ path: String) -> LosselessEndpointRepresentable! {
        return EndpointPath(rawValue: (basePath+endpointPath+path).replacingOccurrences(of: "//", with: "/"))
    }
    
    // MARK: URL components
    /// The base path.
    public var basePath: String {
        switch self {
        case .v1: return "https://i.instagram.com/api/v1"
        case .v2: return "https://i.instagram.com/api/v2"
        case .generic: return "https://www.instagram.com"
        }
    }
    /// The main path component.
    public var endpointPath: String {
        switch self {
        case .v1(let path), .v2(let path), .generic(let path):
            return path
        }
    }
    /// The `URLComponents`.
    public var components: URLComponents? {
        var components = URLComponents(string: basePath)
        components?.path = endpointPath
        return components
    }
    
    // MARK: Description
    public var description: String { return basePath+endpointPath }
}
/// Extend `EndpointPath` to make it `RawRepresentable`.
extension EndpointPath: RawRepresentable, ExpressibleByStringLiteral, Equatable {
    /// Init with `stringLiteral`.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
    /// Init with `rawValue`.
    public init?(rawValue: String) {
        if rawValue.hasPrefix("https://i.instagram.com/api/v1") {
            self = .v1(String(rawValue.dropFirst("https://i.instagram.com/api/v1".count)))
        } else if rawValue.hasPrefix("https://i.instagram.com/api/v2") {
            self = .v2(String(rawValue.dropFirst("https://i.instagram.com/api/v2".count)))
        } else if rawValue.hasPrefix("https://www.instagram.com") {
            self = .generic(String(rawValue.dropFirst("https://www.instagram.com".count)))
        } else {
            return nil
        }
    }

    /// The raw value.
    public var rawValue: String {
        if endpointPath.hasPrefix("/") {
            return basePath+endpointPath
        } else {
            return basePath+"/"+endpointPath
        }
    }
}
