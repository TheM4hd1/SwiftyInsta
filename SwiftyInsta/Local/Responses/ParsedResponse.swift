//
//  ParsedResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/30/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `protocol` holding reference to endpoint responses.
public protocol ParsedResponse: Codable {
    /// The associated `JSON` response.
    var rawResponse: DynamicResponse { get }

    /// Init with `rawResponse`.
    init?(rawResponse: DynamicResponse)
}

/// The identifier type.
/// Most of `Instagram` models for their responses, contain both a numerical `pk`, representing the _primaryKey_ (i.e. unique)
/// of the element in the _database_, and a string `id`, which is usually used to acces their info from the outside
/// (and it's supposed to still be unique).
/// `Identifier<Element>` allows to store everything related to "identifying" a response in one place, while also,
/// thanks to the `Element` reference, allow for type specific comparisons.
public struct Identifier<Element>: Hashable {
    /// The **numerical** primary key.
    public var primaryKey: Int?
    /// The **string** identifier.
    public var identifier: String?

    /// Init with `primaryKey` and `identifier`.
    public init(primaryKey: Int? = nil, identifier: String? = nil) {
        self.primaryKey = primaryKey
        self.identifier = identifier
    }
    /// Return a copy with an updated `primaryKey`.
    public func primaryKey(_ primaryKey: Int) -> Identifier<Element> {
        return .init(primaryKey: primaryKey, identifier: self.identifier)
    }
    /// Return a copy with an updated `identifier`.
    public func identifier(_ identifier: String) -> Identifier<Element> {
        return .init(primaryKey: self.primaryKey, identifier: identifier)
    }
}
/// An **identifiable** `ParsedResponse`.
public protocol IdentifiableParsedResponse: ParsedResponse {
    /// The identifier.
    var identity: Identity { get }
}
/// The defaullt implementation.
public extension IdentifiableParsedResponse {
    /// The identifier type.
    typealias Identity = Identifier<Self>
    /// The identifier.
    var identity: Identifier<Self> {
        return .init(primaryKey: rawResponse.pk.int ?? rawResponse.pk.string.flatMap(Int.init),
                     identifier: rawResponse.id.string)
    }
}

/// A **user identifiable** `ParsedResponse`.
public protocol UserIdentifiableParsedResponse: ParsedResponse {
    /// The user identifier.
    var userIdentity: Identifier<User> { get }
}
/// The default implementation.
public extension UserIdentifiableParsedResponse {
    /// The user identifier.
    var userIdentity: Identifier<User> {
        return .init(primaryKey: rawResponse.userPk.int ?? rawResponse.userPk.string.flatMap(Int.init),
                     identifier: rawResponse.userId.string)
    }
}

/// A **thread identifiable** `ParsedResponse`.
public protocol ThreadIdentifiableParsedResponse: ParsedResponse {
    /// The thread identifier.
    var threadIdentifier: Identifier<Thread> { get }
}
/// The default implementation.
public extension ThreadIdentifiableParsedResponse {
    /// The thread identifier.
    var threadIdentifier: Identifier<Thread> {
        return .init(primaryKey: nil,
                     identifier: rawResponse.threadId.string)
    }
    /// The account identifier.
    var viewerIdentifier: Identifier<User> {
        return .init(primaryKey: rawResponse.viewerId.int ?? rawResponse.viewerId.string.flatMap(Int.init),
                     identifier: nil)
    }
}

/// An **item identifiable** `ParsedResponse`.
public protocol ItemIdentifiableParsedResponse: ParsedResponse {
    /// The item identifier.
    var itemIdentifier: Identifier<Message> { get }
}
/// The default implementation.
public extension ItemIdentifiableParsedResponse {
    /// The item identifier.
    var itemIdentifier: Identifier<Message> {
        return .init(primaryKey: nil,
                     identifier: rawResponse.itemId.string)
    }
}

/// An **cover identifiable** `ParsedResponse`.
public protocol CoverIdentifiableParsedResponse: ParsedResponse {
    /// The media identifier.
    var mediaIdentifier: Identifier<Media> { get }
}
/// The default implementation.
public extension CoverIdentifiableParsedResponse {
    /// The media identifier.
    var mediaIdentifier: Identifier<Media> {
        return .init(primaryKey: nil,
                     identifier: rawResponse.mediaId.string)
    }
}
