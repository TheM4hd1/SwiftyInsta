//
//  BaseStatusResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

protocol BaseStatusResponseProtocol {
    var status: String? { get }
}

public struct BaseStatusResponseModel: Codable, BaseStatusResponseProtocol {
    public var status: String?
    public var message: StatusMessageModel?
    
    public init(status: String?, message: StatusMessageModel?) {
        self.status = status
        self.message = message
    }
    
    func isOk() -> Bool {
        if let status = status {
            if !status.isEmpty && status.lowercased() == "ok" {
                return true
            }
        }
        return false
    }
    
    func isFail() -> Bool {
        if let status = status {
            if !status.isEmpty && status.lowercased() == "fail" {
                return true
            }
        }
        return false
    }
}

public struct StatusMessageModel: Codable {
    public var errors: [String]?
    
    public init(errors: [String]?) {
        self.errors = errors
    }
}
