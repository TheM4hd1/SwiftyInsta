//
//  Device.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/31/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import CryptoSwift
import Foundation

/// A `protocol` defyining a `Device` generator.
public protocol DeviceGenerating {
    /// Generate the specific `Device`.
    func generate() -> Device
}

/// A `struct` holding reference to a specific device info.
public struct Device: Codable {
    /// The `deviceBrand`.
    public let brand: String
    /// The `deviceId`.
    public let id: String
    /// The `deviceModel`.
    public let model: String

    /// The phone GUID.
    public let phoneGuid: UUID
    /// The device GUID.
    public let deviceGuid: UUID
    /// The Google AD ID.
    public let googleAdId: UUID
    /// The rank token.
    public let rankToken: UUID

    /// The `androidBoardName`.
    let androidBoardName: String
    /// The `androidBootLoadder`.
    let androidBootLoader: String
    /// The `deviceModelBoot`.
    let deviceModelBoot: String
    /// The `deviceModelIdentifier`.
    let deviceModelIdentifier: String
    /// The `firmwareBrand`.
    let firmwareBrand: String
    /// The `firmwareFingerpint`.
    let firmwareFingerprint: String
    /// The `firmwareTags`.
    let firmwareTags: String
    /// The `firmwareType`.
    let firmwareType: String
    /// The hardwer manufacturer.
    let hardwareManufacturer: String
    /// The hardwer model.
    let hardwareModel: String

    init(brand: String,
         model: String,
         phoneGuid: UUID = .init(),
         deviceGuid: UUID = .init(),
         googleAdId: UUID,
         rankToken: UUID,
         androidBoardName: String,
         androidBootLoader: String,
         deviceModelBoot: String,
         deviceModelIdentifier: String,
         firmwareBrand: String,
         firmwareFingerprint: String,
         firmwareTags: String,
         firmwareType: String,
         hardwareManufacturer: String,
         hardwareModel: String) {
        self.brand = brand
        self.id = "android-\(deviceGuid.uuidString.md5().prefix(16))"
        self.model = model
        self.phoneGuid = phoneGuid
        self.deviceGuid = deviceGuid
        self.googleAdId = googleAdId
        self.rankToken = rankToken
        self.androidBoardName = androidBoardName
        self.androidBootLoader = androidBootLoader
        self.deviceModelBoot = deviceModelBoot
        self.deviceModelIdentifier = deviceModelIdentifier
        self.firmwareBrand = firmwareBrand
        self.firmwareFingerprint = firmwareFingerprint
        self.firmwareTags = firmwareTags
        self.firmwareType = firmwareType
        self.hardwareManufacturer = hardwareManufacturer
        self.hardwareModel = hardwareModel
    }
}
