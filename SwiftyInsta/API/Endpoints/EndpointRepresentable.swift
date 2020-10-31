//
//  EndpointType.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 25/11/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `protocol` describing what it broadly means to be an endpoint.
public protocol EndpointRepresentable {
    /// The endpoint representable.
    var representation: LosselessEndpointRepresentable { get }
}
public extension EndpointRepresentable {
    /// A `throw`-able `URL`.
    func url() throws -> URL { return try representation.url() }

    /// Fill the `userPk`.
    func user(_ userPk: Int) -> EndpointRepresentable! { return representation.user(userPk) }
    /// Fill the `mediaId`.
    func media(_ mediaId: String) -> EndpointRepresentable! { return representation.media(mediaId) }
    /// Fill the `uploadId`.
    func upload(_ uploadId: String) -> EndpointRepresentable! { return representation.upload(uploadId) }
    /// Fill the `commentId`.
    func comment(_ commentId: String) -> EndpointRepresentable { return representation.comment(commentId) }
    /// Fill the `threadId`.
    func thread(_ threadId: String) -> EndpointRepresentable! { return representation.thread(threadId) }
    /// Fill the `tagId`.
    func tag(_ tagId: String) -> EndpointRepresentable! { return representation.tag(tagId) }
    // Fill the `apiPath`.
    func apiPath(_ apiPath: String) -> EndpointRepresentable! { return representation.apiPath(apiPath) }
    // Fill the `bloksAction`.
    func bloksAction(_ bloksAction: String) -> EndpointRepresentable! { return representation.bloksAction(bloksAction) }

    /// Query `maxId`.
    func next(_ maxId: String?) -> EndpointRepresentable! { return representation.next(maxId) }
    /// Query `rankToken`.
    func rank(_ token: String) -> EndpointRepresentable! { return representation.rank(token) }
    /// Query `mediaType`.
    func type(_ mediaType: MediaType) -> EndpointRepresentable! { return representation.type(mediaType) }
    /// Query `q`.
    func q(_ query: String) -> EndpointRepresentable! { return representation.q(query) }
    /// Query `query`.
    func query(_ query: String?) -> EndpointRepresentable! { return representation.query(query) }
    /// Query `deviceId`
    func deviceId(_ deviceId: String) -> EndpointRepresentable! { return representation.deviceId(deviceId) }
    /// Query `challenge_context`
    func challenge(_ context: String) -> EndpointRepresentable! { return representation.challenge(context) }
    /// Appendding `query`.
    func appending(_ path: String) -> EndpointRepresentable! { return representation.appending(path) }
}

/// A `protocol` describing what it counts as an endpoint.
public protocol LosselessEndpointRepresentable: CustomStringConvertible, EndpointRepresentable {
    /// The `URLComponents`.
    var components: URLComponents? { get }

    /// Placeholders.
    var placeholders: [String]? { get }
    /// Fill placeholder and return.
    func filling(_ placeholder: String, with string: String) -> LosselessEndpointRepresentable!

    /// Query.
    func query<L>(_ items: [String: L]) -> LosselessEndpointRepresentable! where L: LosslessStringConvertible

    /// Append path.
    func appending(_ path: String) -> LosselessEndpointRepresentable!
}
/// Accessories.
extension LosselessEndpointRepresentable {
    /// The endpoint representable.
    public var representation: LosselessEndpointRepresentable { return self }

    /// A `throw`-able `URL`.
    func url() throws -> URL {
        guard (placeholders ?? []).isEmpty else {
            throw GenericError.invalidEndpoint(description)
        }
        guard let components = self.components else {
            throw GenericError.invalidEndpoint(description)
        }
        guard let url = components.url else {
            throw GenericError.invalidEndpoint(description)
        }
        return url
    }

    /// Fill the `userPk`.
    func user(_ userPk: Int) -> EndpointRepresentable! { return filling("userPk", with: String(userPk)) }
    /// Fill the `mediaId`.
    func media(_ mediaId: String) -> EndpointRepresentable! { return filling("mediaId", with: mediaId) }
    /// Fill the `uploadId`.
    func upload(_ uploadId: String) -> EndpointRepresentable! { return filling("uploadId", with: uploadId) }
    /// Fill the `commentId`.
    func comment(_ commentId: String) -> EndpointRepresentable { return filling("commentId", with: commentId) }
    /// Fill the `threadId`.
    func thread(_ threadId: String) -> EndpointRepresentable! { return filling("threadId", with: threadId) }
    /// Fill the `tagId`.
    func tag(_ tagId: String) -> EndpointRepresentable! { return filling("tagId", with: tagId) }
    // Fill the `apiPath`.
    func apiPath(_ apiPath: String) -> EndpointRepresentable! { return filling("apiPath", with: apiPath) }
    // Fill the `bloksAction`.
    func bloksAction(_ bloksAction: String) -> EndpointRepresentable! { return filling("bloksAction", with: bloksAction) }

    /// Query `maxId`.
    func next(_ maxId: String?) -> EndpointRepresentable! { return maxId.flatMap { query(["max_id": $0]) } ?? self }
    /// Query `rankToken`.
    func rank(_ token: String) -> EndpointRepresentable! { return query(["rank_token": token]) }
    /// Query `mediaType`.
    func type(_ mediaType: MediaType) -> EndpointRepresentable! { return query(["media_type": mediaType.rawValue]) }
    /// Query `q`.
    func q(_ query: String) -> EndpointRepresentable! { return self.query(["q": query]) }
    /// Query `query`.
    func query(_ query: String?) -> EndpointRepresentable! { return query.flatMap { self.query(["query": $0]) } ?? self }
    /// Query `deviceId`
    func deviceId(_ deviceId: String) -> EndpointRepresentable! { return query(["device_id": deviceId]) }
    /// Query `challenge_context`
    func challenge(_ context: String) -> EndpointRepresentable! { return query(["challenge_context": context]) }
}

/// Extend `RawRepresentable` to mimic `EndpointRepresentable`.
public protocol RawEndpointRepresentable: EndpointRepresentable where Self: RawRepresentable, Self.RawValue: LosselessEndpointRepresentable { }
public extension RawEndpointRepresentable {
    /// The endpoint representable.
    var representation: LosselessEndpointRepresentable { return rawValue }
}
