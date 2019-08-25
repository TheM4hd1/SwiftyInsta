//
//  DynamicResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 08/02/2019.
//  Inspired by https://github.com/saoudrizwan/DynamicJSON
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// An `enum` holding reference to possible `JSON` objects.
public enum DynamicRequest: Equatable {
    /// An `Array`.
    case array([DynamicRequest])
    /// A `Bool`, `Double` or `Int`.
    case number(NSNumber)
    /// A `Dictionary`.
    case dictionary([String: DynamicRequest])
    /// A `String`.
    case string(String)
    /// An empty value.
    case none

    // MARK: Lifecycle
    init(data: Data,
         options: JSONSerialization.ReadingOptions = .allowFragments) throws {
        self = try DynamicRequest(JSONSerialization.jsonObject(with: data, options: options))
    }

    public init(_ object: Any) {
        switch object {
        // match `Array`.
        case let array as [Any]:
            self = .array(array.map { DynamicRequest($0) })
        // match `Bool`, `Double` or `Int`.
        case let number as NSNumber:
            self = .number(number)
        // match `Data`.
        case let data as Data:
            self = (try? DynamicRequest(data: data)) ?? .none
        // match `Dictionary`.
        case let dictionary as [String: Any]:
            self = .dictionary(Dictionary(uniqueKeysWithValues: dictionary.map {
                ($0.key, DynamicRequest($0.value))
            }))
        // match `String`.
        case let string as String:
            self = .string(string)
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
        case .dictionary(let dictionary): return dictionary.mapValues { $0.any }
        case .number(let number): return number
        case .string(let string): return string
        case .none: return NSNull()
        }
    }
}
extension DynamicRequest: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }
}
extension DynamicRequest: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .number(value as NSNumber)
    }
}
extension DynamicRequest: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        let dictionary = elements.reduce(into: [String: Any](), { $0[$1.0] = $1.1})
        self.init(dictionary)
    }
}
extension DynamicRequest: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value as NSNumber)
    }
}
extension DynamicRequest: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(value as NSNumber)
    }
}
extension DynamicRequest: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}
extension DynamicRequest: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}
