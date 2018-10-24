//
//  APIRequestModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

struct RequestMessageModel: Codable {
    var phoneId: String
    var username: String
    var guid: UUID
    var deviceId: String
    var password: String
    var loginAttemptCount: String = "0"
    
    func getMessageString() -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let data  = try encoder.encode(self)
            let message = String(data: data, encoding: String.Encoding.utf8)
            return message ?? ""
        } catch {
            fatalError("getMessageString() fatalError.")
        }
    }
    
    func generateSignature(signatureKey: String) -> String {
        return ""
    }
    
    func isEmpty() -> Bool {
        if phoneId.isEmpty || deviceId.isEmpty {
            return true
        }
        return false
    }
    
    static func generateDeviceId() -> String {
        return ""
    }
    
    func generateUploadId() -> String {
        return ""
    }
    
    func fromDevice(device: AndroidDeviceModel) -> RequestMessageModel {
        let model = RequestMessageModel(phoneId: device.phoneGuid.uuidString, username: "",
                                        guid: device.deviceGuid, deviceId: device.deviceId, password: "", loginAttemptCount: "0")
        return model
    }
    
    static func generateDeviceIdFromGuid(guid: UUID) -> String {
        return ""
    }
}
