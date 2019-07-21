//
//  SessionStorage.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct SessionStorage: Codable {
    public var dsUserId: String
    public var csrfToken: String
    public var rankToken: String
    public var user: CurrentUser?
}
