//
//  Extensions.swift
//  SwiftyInsta
//
//  Created by Mahdi on 11/19/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// `Data` accesories.
extension Data {
    @discardableResult
    /// Append `string` to `self`. Returns `true` if successful, `false` otherwise.
    mutating func append(string: String) -> Bool {
        guard let data = string.data(using: .utf8, allowLossyConversion: true) else { return false }
        append(data)
        return true
    }
}

/// `Date` accessories.
extension Date {
    /// Return `1_000 * timeIntervalSince1970`, rounding to nearest `Int`.
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    /// Create a `Date` from `Int` `milliseconds` since 1970.
    init(millisecondsSince1970 milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

/// A `protocol` for converting `HTTPCookie` to `Data`.
protocol CookieEncodable {
    /// Return related `Data`.
    var data: Data? { get }
}
/// `Collection`s of `CookieEncodable` should behave similarly to `CookieEncodable`.
extension Collection where Element: CookieEncodable {
    /// Return related `[Data]`.
    var data: [Data] { return compactMap { $0.data }}
}
/// `HTTPCookie` accesories.
extension HTTPCookie: CookieEncodable {
    /// Save the cookie `properties`.
    private func saveProperties(_ properties: [HTTPCookiePropertyKey: Any]) -> Data? {
        if #available(iOS 11, OSX 10.13, tvOS 11, watchOS 4, *) {
            return try? NSKeyedArchiver.archivedData(withRootObject: properties,
                                                     requiringSecureCoding: true)
        } else {
            return NSKeyedArchiver.archivedData(withRootObject: properties)
        }
    }
    /// Load the cookie properties from `data`.
    private static func loadProperties(from data: Data) -> [HTTPCookiePropertyKey: Any]? {
        if #available(iOS 11, OSX 10.13, tvOS 11, watchOS 4, *) {
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookiePropertyKey: Any]
        } else {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [HTTPCookiePropertyKey: Any]
        }
    }

    /// Load `HTTPCookie`.
    static func load(from data: Data?) -> HTTPCookie? {
        return data.flatMap(loadProperties).flatMap(HTTPCookie.init)
    }
    /// Get `Data` from cookie.
    var data: Data? { return properties.flatMap(saveProperties) }
}

/// `CharacterSet` accesories.
extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}
