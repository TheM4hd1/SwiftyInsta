//
//  ChallengeModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/29/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct ChallengeModel: Codable {
    public var url: String
    public var apiPath: String
    public var hideWebviewHeader: Bool
    public var lock: Bool
    public var logout: Bool
    public var nativeFlow: Bool
    
    public init(url: String, apiPath: String, hideWebviewHeader: Bool, lock: Bool, logout: Bool, nativeFlow: Bool) {
        self.url = url
        self.apiPath = apiPath
        self.hideWebviewHeader = hideWebviewHeader
        self.lock = lock
        self.logout = logout
        self.nativeFlow = nativeFlow
    }
}
