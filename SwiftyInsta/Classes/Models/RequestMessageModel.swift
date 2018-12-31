//
//  APIRequestModel.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct RequestMessageModel: Codable {
    public var phoneId: String
    public var username: String
    public var guid: UUID
    public var deviceId: String
    public var password: String
    public var loginAttemptCount: String = "0"
    
    public init(phoneId: String, username: String, guid: UUID, deviceId: String, password: String, loginAttemptCount: String = "0") {
        self.phoneId = phoneId
        self.username = username
        self.guid = guid
        self.deviceId = deviceId
        self.password = password
        self.loginAttemptCount = loginAttemptCount
    }
    
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
        var _signatureKey = signatureKey
        if signatureKey.isEmpty {
            _signatureKey = Headers.HeaderIGSignatureValue
        }
        
        let message = getMessageString()
        return message.hmac(algorithm: .SHA256, key: _signatureKey)
    }
    
    func isEmpty() -> Bool {
        if phoneId.isEmpty || deviceId.isEmpty {
            return true
        }
        return false
    }
    
    static func generateDeviceId() -> String {
        return generateDeviceIdFromGuid(guid: UUID.init())
    }
    
    func generateUploadId() -> String {
//        var dateComponents = DateComponents()
//        dateComponents.year = 1970
//        dateComponents.month = 1
//        dateComponents.day = 1
//        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
//        let date = Calendar.current.date(from: dateComponents)
//        let timeSpan = Date().timeIntervalSince(date!)
//        let totalSeconds = Int(timeSpan)
//        return String(totalSeconds)
        return String(Date().millisecondsSince1970 / 1000)
    }
    
    func fromDevice(device: AndroidDeviceModel) -> RequestMessageModel {
        let model = RequestMessageModel(
            phoneId: device.phoneGuid.uuidString,
            username: "",
            guid: device.deviceGuid,
            deviceId: device.deviceId,
            password: "",
            loginAttemptCount: "0"
        )
        return model
    }
    
    static func generateDeviceIdFromGuid(guid: UUID) -> String {
        let hashedGuid = guid.uuidString.MD5
        return "android-\(hashedGuid.prefix(16))"
    }
}
