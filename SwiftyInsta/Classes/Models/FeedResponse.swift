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
    public init(rawResponse: DynamicResponse) {
        if rawResponse.stories != .none {
            self = .story(.init(rawResponse: rawResponse.stories))
        } else if rawResponse.media != .none {
            self = .media(.init(rawResponse: rawResponse.media))
        } else {
            self = .none
        }
    }
}
