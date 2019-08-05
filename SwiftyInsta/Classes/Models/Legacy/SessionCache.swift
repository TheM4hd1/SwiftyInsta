//
//  SessionCache.swift
//  SwiftyInsta
//
//  Created by Mahdi on 1/4/19.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct SessionCache: Codable {
    /// The default storage.
    public var storage: SessionStorage?
    /// The device in use.
    public var device: Device
    /// The `HTTPCookie` stored as `Data`.
    let cookies: [Data]
}
