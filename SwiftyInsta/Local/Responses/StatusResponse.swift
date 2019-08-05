//
//  Status.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  V. 2.0 by Stefano Bertagno on 7/31/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

/// A `protocol` referencing to everything holding an `Optional` **string** `status`.
protocol StatusEnforceable {
    /// The current `status`.
    var status: String? { get }
}

/// A basic `struct` conforming to `StatusEnforceable`.
public struct Status: Codable, StatusEnforceable {
    /// The current `state`.
    public enum State {
        case ok, fail, unknown
    }

    /// The current `status`.
    public var status: String?
    /// The current `state`.
    public var state: State {
        switch status?.lowercased() {
        case "ok"?: return .ok
        case "fail"?: return .fail
        default: return .unknown
        }
    }
}
