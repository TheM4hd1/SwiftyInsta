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
    public var device: AndroidDeviceModel
    /// The cookies.
    public let cookies: [Data]
    
    /// use this function from Siwa framework.
    public static func from(cookies: [Data]) -> SessionCache {
        return .init(storage: nil,
                     device: AndroidDeviceGenerator.getRandomAndroidDevice(),
                     cookies: cookies)
    }
}
