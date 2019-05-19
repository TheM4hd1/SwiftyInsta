//
//  SessionCache.swift
//  SwiftyInsta
//
//  Created by Mahdi on 1/4/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct SessionCache: Codable {
    public let user: SessionStorage
    public let device: AndroidDeviceModel
    public let requestMessage: RequestMessageModel
    public let cookies: [Data]
    public let isUserAuthenticated: Bool
    
    /// use this function from Siwa framework.
    public static func from(cookies: [Data]) -> SessionCache {
        return self.init(user: SessionStorage.create(username: "username", password: "password"), device: HandlerSettings.shared.device!, requestMessage: HandlerSettings.shared.request!, cookies: cookies, isUserAuthenticated: true)
    }
}
