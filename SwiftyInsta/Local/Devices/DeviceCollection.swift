//
//  DeviceCollection.swift
//  SwiftyInsta
//
//  Created by Stefano Bertagno on 07/31/2019.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// A `protocol` defyining `Brand` properties.
public protocol DeviceCollection {
    /// Mimic `CaseIterable` conformacy.
    static var all: [DeviceCollection & DeviceGenerating] { get }
}
public extension DeviceCollection {
    /// Return a random `Device` for the given `Brand`.
    static func random() -> Device! {
        return all.randomElement()?.generate()
    }
}

/// Any device.
public struct AnyDevice: DeviceCollection {
    /// Return all `Device`s.
    public static var all: [DeviceCollection & DeviceGenerating] {
        let collections: [[DeviceCollection & DeviceGenerating]] = [HTC.allCases,
                                                                    LG.allCases,
                                                                    Samsung.allCases,
                                                                    Sony.allCases]
        return collections.reduce(into: []) { result, next in result = result+next }
    }
}
