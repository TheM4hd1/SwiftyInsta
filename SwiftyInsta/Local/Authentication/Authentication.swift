//
//  Authentication.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 09/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation
import KeychainSwift

/// An abstract `struct` holding login references .
public struct Authentication {
    #if canImport(WebKit)
    /// Select the way you wish to authenticate.
    public enum Request {
        /// Log in with username and password.
        case user(Credentials)

        /// Log in through web view.
        case webView(LoginWebView)

        /// Log in using `Authentication.Response` (either a stored one, or through `Siwa`).
        case cache(Authentication.Response)
    }
    #else
    /// Select the way you wish to authenticate.
    public enum Request {
        /// Log in with username and password.
        case user(Credentials)
        /// Log in using `Authentication.Response` (either a stored one, or through `Siwa`).
        case cache(Authentication.Response)
    }
    #endif

    /// Cookies, device, and other useful info return by a successful authentication process.
    public struct Response: Codable {
        /// The device in use.
        public var device: Device

        /// The cached value for the logged-in `User` `primaryKey`.
        public var identifier: String? { return storage?.dsUserId }
        /// The cached value for the logged-in `User`.
        public var user: User? { return storage?.user }

        /// The default storage.
        var storage: Storage?
        /// The `HTTPCookie` stored as `Data`.
        let data: [Data]
        //// The `HTTPCookie`s.
        var cookies: [HTTPCookie] { return data.compactMap(HTTPCookie.load) }

        /// Store the cache **if valid** in the user's keychain.
        /// You can save the returned value safely in your `UserDefaults`, or your database
        /// and then retrieve the `Response` when needed.
        /// - Parameters:
        ///     - access: An optional `KeychainSwiftAccessOptions` value.
        /// - Returns: The `key` used to store `Response` in your keychahin (the logged user's `pk`). `nil` otherwise.
        public func persist(withAccess access: KeychainSwiftAccessOptions? = nil) -> String? {
            let encoder = JSONEncoder()

            guard let dsUserId = storage?.dsUserId,
                !dsUserId.isEmpty,
                let data = try? encoder.encode(self) else { return nil }
            // update keychain.
            let keychain = KeychainSwift()
            keychain.set(data, forKey: dsUserId, withAccess: access)
            return dsUserId
        }

        /// Init a `Response` with the data stored in the user's keychain
        /// and persisted through `Authentication.Response.persist()`.
        /// - Parameters:
        ///     - key: The `String` returned by `Authentication.Response.persist()`
        /// - Returns: The `Response` if valid `Data` is found in the keychain, `nil` otherwise.
        public static func persisted(with key: String) -> Response? {
            let keychain = KeychainSwift()
            let decoder = JSONDecoder()
            guard let data = keychain.getData(key) else { return nil }
            // decode and return.
            return try? decoder.decode(Response.self, from: data)
        }

        @discardableResult
        /// Remove a persisted `Response` from the user's keychain.
        /// - Parameters:
        ///     - key: The `String` returned by `Authentication.Response.persist()`
        /// - Returns: `true` if it was found and deleted, `false` otherwise.
        public static func invalidate(persistedWithKey key: String) -> Bool {
            return KeychainSwift().delete(key)
        }

        @discardableResult
        /// Remove the persisted `Response` from the user's keychain.
        /// - Returns: `true` if it was found and deleted, `false` otherwise.
        public func invalidate() -> Bool {
            guard let dsUserId = storage?.dsUserId, !dsUserId.isEmpty else { return false }
            return KeychainSwift().delete(dsUserId)
        }
    }

    /// A `struct` holding reference to all the authentication most sensiblle cookie values.
    struct Storage: Codable {
        var dsUserId: String
        var csrfToken: String
        var sessionId: String
        var rankToken: String
        var user: User?
    }
}
