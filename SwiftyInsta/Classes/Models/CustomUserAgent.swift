//
//  CustomUserAgent.swift
//  SwiftyInsta
//
//  Created by Mahdi on 2/16/19.
//  V. 2.0 by Stefano Bertagno on 7/21/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct CustomUserAgent {
    public let apiVersion: String
    public let osName: String
    public let osVersion: String
    public let osRelease: String
    public let dpi: String
    public let resolution: String
    public let company: String
    public let model: String
    public let modem: String
    public let locale: String
    public let fbCode: String

    /// Compute and return the user agent.
    public var string: String {
        return String(format: "Instagram %@ %@ (%@/%@; %@dpi; %@; %@; %@; %@; %@; %@; %@)",
                      apiVersion, osName, osVersion, osRelease, dpi, resolution, company, model, model, modem, locale, fbCode)
    }

    /// Manually create a user-agent.
    public init(apiVersion: String = "85.0.0.21.100",
                osName: String = "Android",
                osVersion: String = "21",
                osRelease: String = "5.0.2",
                dpi: String = "480",
                resolution: String = "1080x1776",
                company: String = "Sony",
                model: String = "C6603",
                modem: String = "qcom",
                locale: String = Locale.current.identifier,
                fbCode: String = "95414346") {
        self.apiVersion = apiVersion
        self.osName = osName
        self.osVersion = osVersion
        self.osRelease = osRelease
        self.dpi = dpi
        self.resolution = resolution
        self.company = company
        self.model = model
        self.modem = modem
        self.locale = locale
        self.fbCode = fbCode
    }
    /// Create user agent based on device.
    public init(device: AndroidDeviceModel) {
        self.apiVersion = "85.0.0.21.100"
        self.osName = "Android"
        let version = device.frimwareFingerprint.split(separator: "/")[2].split(separator: ":")[1]
        let androidVersion = AndroidVersion.fromString(versionString: String(version))!
        self.osVersion = String(androidVersion.versionNumber.split(separator: ".").first!)
        self.osRelease = String(androidVersion.versionNumber.split(separator: ".").last!)
        self.dpi = "640dpi"
        self.resolution = "1440x2560"
        self.company = device.deviceBrand
        self.model = device.deviceModel
        self.modem = device.deviceModelBoot
        self.locale = Locale.current.identifier
        self.fbCode = "146536611"
    }
}
