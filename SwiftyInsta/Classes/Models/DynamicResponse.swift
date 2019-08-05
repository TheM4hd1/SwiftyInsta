//
//  DynamicResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 08/02/2019.
//  Inspired by https://github.com/saoudrizwan/DynamicJSON.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// `String` extension to convert `snake_case` into `camelCase`, and back.
public extension String {
    /// To `camelCase`.
    var camelCased: String {
        return split(separator: "_")
            .map(String.init)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    /// To `snake-case`.
    var snakeCased: String {
        return reduce(into: "") { result, new in
            result += new.isUppercase ? "-"+String(new).lowercased() : String(new)
        }
    }
}

@dynamicMemberLookup
/// An `enum` holding reference to possible `JSON` objects.
public enum DynamicResponse: Equatable {
    /// An `Array`.
    case array([DynamicResponse])
    /// A `Bool`.
    case bool(Bool)
    /// A `Double`.
    case double(Double)
    /// An `Int`.
    case int(Int)
    /// A `Dictionary`.
    case dictionary([String: DynamicResponse])
    /// A `String`.
    case string(String)
    /// A `URL`.
    case url(URL)
    /// An empty value.
    case none

    // MARK: Lifecycle
    init(data: Data,
         options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        self = try DynamicResponse(JSONSerialization.jsonObject(with: data, options: options))
    }

    public init(_ object: Any) {
        switch object {
        // match `Array`.
        case let array as [Any]:
            self = .array(array.map(DynamicResponse.init))
        // match `Bool`.
        case let bool as Bool:
            self = .bool(bool)
        // match `Int`.
        case let int as Int:
            self = .int(int)
        // match `Double`.
        case let double as Double:
            self = .double(double)
        // match `Data`.
        case let data as Data:
            self = (try? DynamicResponse(data: data)) ?? .none
        // match `Dictionary`.
        case let dictionary as [String: Any]:
            self = .dictionary(Dictionary(uniqueKeysWithValues: dictionary.map { ($0.key.camelCased, DynamicResponse($0.value)) }))
        // match `String`.
        case let string as String:
            self = URL(string: string).flatMap(DynamicResponse.url) ?? .string(string)
        // anything else.
        default:
            self = .none
        }
    }

    func data(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: any, options: options)
    }

    // MARK: Accessories
    /// `Any`.
    public var any: Any {
        switch self {
        case .array(let array): return array.map { $0.any }
        case .bool(let bool): return bool
        case .dictionary(let dictionary): return dictionary.mapValues { $0.any }
        case .double(let double): return double
        case .int(let int): return int
        case .string(let string): return string
        case .url(let url): return url
        case .none: return NSNull()
        }
    }

    /// `[DynamicResponse]` if `.array` or `nil`.
    public var array: [DynamicResponse]? {
        guard case let .array(array) = self else { return nil }
        return array
    }

    /// `Bool` if  `.bool`, `.int`, `.string` or `nil`.
    public var bool: Bool? {
        switch self {
        case .bool(let bool): return bool
        case .int(let int) where int >= 0: return int != 0
        case .string(let string) where ["yes", "y", "true", "t", "1"].contains(string.lowercased()):
            return true
        case .string(let string) where ["no", "n", "false", "f", "0"].contains(string.lowercased()):
            return false
        default: return nil
        }
    }

    /// `[String: DynamicResponse]` if `.dictionary` or `nil`.
    public var dictionary: [String: DynamicResponse]? {
        guard case let .dictionary(dictionary) = self else { return nil }
        return dictionary
    }

    /// `Double` if `.double`, `.int` or `nil`.
    public var double: Double? {
        switch self {
        case .double(let double): return double
        case .int(let int): return Double(int)
        default: return nil
        }
    }

    /// `Int` if `.int` or `nil`.
    public var int: Int? {
        guard case let .int(int) = self else { return nil }
        return int
    }

    /// `String` if `.string`, `.url` or `nil`.
    public var string: String? {
        switch self {
        case .url(let url): return url.absoluteString
        case .string(let string): return string
        case .int(let int): return String(format: "%ld", int)
        default: return nil
        }
    }

    /// `URL` if `.url` or `nil`.
    public var url: URL? {
        guard case let .url(url) = self else { return nil }
        return url
    }

    // MARK: Subscripts
    /// Interrogate `.dictionary`.
    public subscript(dynamicMember member: String) -> DynamicResponse {
        guard case let .dictionary(dictionary) = self else { return .none }
        return dictionary[member] ?? .none
    }

    /// Access `index`-th item in `.array`.
    public subscript(index: Int) -> DynamicResponse {
        guard case let .array(array) = self,
            index >= 0 && index < array.count else { return .none }
        return array[index]
    }

    /// Interrogate `.dictionary`.
    public subscript(key: String) -> DynamicResponse {
        guard case let .dictionary(dictionary) = self else { return .none }
        return dictionary[key] ?? .none
    }
}
extension DynamicResponse: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
extension DynamicResponse: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}
extension DynamicResponse: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(elements)
    }
}
extension DynamicResponse: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .double(value)
    }
}
extension DynamicResponse: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .int(value)
    }
}
extension DynamicResponse: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}
extension DynamicResponse: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = URL(string: value).flatMap(DynamicResponse.url) ?? .string(value)
    }
}
