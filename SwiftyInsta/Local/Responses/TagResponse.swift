//
//  File.swift
//  
//
//  Created by Zeeshan Ahmed on 08/09/2020.
//

import Foundation

/// A `Tag` response.
public struct Tag: IdentifiableParsedResponse {
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        guard rawResponse != .none else { return nil }
        self.rawResponse = rawResponse
    }
    
    /// The `rawResponse`.
    public let rawResponse: DynamicResponse
    
    /// The `name` value.
    public var name: String { return rawResponse.name.string ?? "" }
    
    /// The `mediaCount` value.
    public var mediaCount: Int { return rawResponse.mediaCount.int ?? 0 }
    
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
