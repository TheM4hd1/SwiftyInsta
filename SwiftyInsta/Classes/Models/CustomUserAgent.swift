//
//  CustomUserAgent.swift
//  SwiftyInsta
//
//  Created by Mahdi on 2/16/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct CustomUserAgent {
    public let apiVersion: String //78.0.0.9.103
    public let osName: String //Android
    public let osVersion: String //21
    public let osRelease: String //5.0.2
    public let dpi: String //480
    public let resolution: String //1080x1776
    public let company: String //Sony
    public let model: String //C6603
    public let modem: String //qcom
    public let locale: String //ru_RU
    public let fbCode: String //95414346
    
    public init(apiVersion: String, osName: String, osVersion: String, osRelease: String, dpi: String, resolution: String, company: String, model: String, modem: String, locale: String, fbCode: String) {
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
    
    public func toString() -> String {
        //"Instagram 78.0.0.9.103 Android (21/5.0.2; 480dpi; 1080x1776; Sony; C6603; C6603; qcom; ru_RU; 95414346)"
        let userAgent = "Instagram %@ %@ (%@/%@; %@dpi; %@; %@; %@; %@; %@; %@; %@)"
        return String(format: userAgent, apiVersion, osName, osVersion, osRelease, dpi, resolution, company, model, model, modem, locale, fbCode)
    }
}
