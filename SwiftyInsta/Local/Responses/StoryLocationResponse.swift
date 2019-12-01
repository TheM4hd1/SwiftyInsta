//
//  StoryLocationResponse.swift
//  SwiftyInsta.iOS
//
//  Created by Stefano Bertagno on 17/09/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import CoreGraphics
import Foundation

/// A `StoryLocation` response.
public struct StoryLocation: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }

    /// The `rawResponse`.
    public let rawResponse: DynamicResponse
    /// The `identity`.
    public var identity: Identifier<StoryLocation> {
        return .init(primaryKey: rawResponse.location.pk.int, identifier: nil)
    }

    /// The `location.address` value.
    public var address: String? {
        return rawResponse.location.address.string
    }
    /// The `location.city` value.
    public var city: String? {
        return rawResponse.location.city.string
    }
    /// The `coordinates` value.
    public var coordinates: CGPoint {
        let x = rawResponse.location.lat.double ?? .nan
        let y = rawResponse.location.lng.double ?? .nan
        return .init(x: x, y: y)
    }
    /// The `location.name` value.
    public var name: String {
        return rawResponse.location.name.string ?? ""
    }
    /// The `location.shortName` value.
    public var shortName: String {
        return rawResponse.location.shortName.string ?? ""
    }

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawResponse = try DynamicResponse(data: container.decode(Data.self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
}
