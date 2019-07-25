//
//  AndroidDevice.swift
//  SwiftyInsta
//
//  Created by Mahdi on 10/24/18.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2018 Mahdi. All rights reserved.
//

import Foundation

public struct AndroidDeviceModel: Codable {
    var phoneGuid: UUID
    var deviceGuid: UUID
    var googleAdId: UUID?
    var rankToken: UUID?
    var androidBoardName: String
    var androidBootLoader: String
    var deviceBrand: String
    var deviceId: String
    var deviceModel: String
    var deviceModelBoot: String
    var deviceModelIdentifier: String
    var frimwareBrand: String
    var frimwareFingerprint: String
    var frimwareTags: String
    var frimwareType: String
    var hardwareManufacturer: String
    var hardwareModel: String

    public var userAgent: CustomUserAgent { return CustomUserAgent(device: self) }
}
