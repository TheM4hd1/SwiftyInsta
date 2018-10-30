//
//  BaseStatusResponseModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/30/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct BaseStatusResponseModel: Codable {
    var status: String?
    
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
