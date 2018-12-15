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
    var status: String?
    var message: StatusMessageModel?
    
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

struct StatusMessageModel: Codable {
    var errors: [String]?
}
