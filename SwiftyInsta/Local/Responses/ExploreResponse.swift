//
//  ExploreResponse.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 05/08/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// An `ExploreElement` response.
public enum ExploreElement: ParsedResponse {
    /// The `story`,
    case story(Tray)
    /// The `media`.
    case media(Media)
    /// None.
    case none

    /// The raw response.
    public var rawResponse: DynamicResponse {
        switch self {
        case .story(let tray): return tray.rawResponse
        case .media(let media): return media.rawResponse
        case .none: return .none
        }
    }
    /// Init with `rawResponse`.
    public init?(rawResponse: DynamicResponse) {
        if rawResponse.stories != .none, let tray = Tray(rawResponse: rawResponse.stories) {
            self = .story(tray)
        } else if rawResponse.media != .none, let media = Media(rawResponse: rawResponse.media) {
            self = .media(media)
        } else {
            return nil
        }
    }

    // MARK: Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let response = try ExploreElement(rawResponse: DynamicResponse(data: container.decode(Data.self))) else {
            throw GenericError.custom("Invalid response. `init(from:)` returned `nil`.")
        }
        self = response
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawResponse.data())
    }
}
