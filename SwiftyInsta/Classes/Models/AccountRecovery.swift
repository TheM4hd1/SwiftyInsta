//
//  AccountRecovery.swift
//  SwiftyInsta
//
//  Created by Mahdi on 2/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct AccountRecovery: Codable, BaseStatusResponseProtocol {
    public var title: String?
    public var body: String?
    public var status: String?
}
